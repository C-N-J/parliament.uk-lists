require 'rails_helper'

RSpec.describe PartiesController, vcr: true do
  describe 'GET index' do
    before(:each) do
      get :index
    end

    it 'should have a response with http status ok (200)' do
      expect(response).to have_http_status(:ok)
    end

    it 'assigns @parties and @letters' do
      assigns(:parties).each do |party|
        expect(party).to be_a(Grom::Node)
        expect(party.type).to eq('https://id.parliament.uk/schema/Party')
      end

      expect(assigns(:letters)).to be_a(Array)
    end

    it 'assigns @parties in alphabetical order' do
      expect(assigns(:parties)[0].name).to eq('partyName - 1')
      expect(assigns(:parties)[1].name).to eq('partyName - 10')
    end

    it 'renders the index template' do
      expect(response).to render_template('index')
    end
  end

  describe 'GET current' do
    before(:each) do
      get :current
    end

    it 'should have a response with http status ok (200)' do
      expect(response).to have_http_status(:ok)
    end

    it 'should return the current number of parties' do
      expect(assigns(:parties).size).to eq(18)
    end

    it 'assigns @parties' do
      assigns(:parties).each do |party|
        expect(party).to be_a(Grom::Node)
        expect(party.type).to eq('https://id.parliament.uk/schema/Party')
      end
    end

    it 'assigns @parties in alphabetical order' do
      expect(assigns(:parties)[0].name).to eq('partyName - 1')
      expect(assigns(:parties)[1].name).to eq('partyName - 10')
    end

    it 'renders the current template' do
      expect(response).to render_template('current')
    end
  end

  describe 'GET letters' do
    context 'valid parties' do
      before(:each) do
        get :letters, params: { letter: 'l' }
      end

      it 'should have a response with http status ok (200)' do
        expect(response).to have_http_status(:ok)
      end

      it 'assigns @parties and @letters' do
        assigns(:parties).each do |party|
          expect(party).to be_a(Grom::Node)
          expect(party.type).to eq('https://id.parliament.uk/schema/Party')
        end

        expect(assigns(:letters)).to be_a(Array)
      end

      it 'assigns @parties in alphabetical order' do
        expect(assigns(:parties)[0].name).to eq('partyName - 1')
        expect(assigns(:parties)[1].name).to eq('partyName - 2')
      end

      it 'renders the letters template' do
        expect(response).to render_template('letters')
      end
    end

    context 'invalid parties' do
      before(:each) do
        get :letters, params: { letter: 'x' }
      end

      it 'should return a 200 status' do
        expect(response).to have_http_status(200)
      end

      it 'should populate @parties with an empty array' do
        expect(controller.instance_variable_get(:@parties)).to be_empty
      end
    end
  end

  describe "GET a_to_z" do
    before(:each) do
      get :a_to_z
    end

    it 'should have a response with http status ok (200)' do
      expect(response).to have_http_status(:ok)
    end

    it 'assigns @letters' do
      expect(assigns(:letters)).to be_a(Array)
    end

    it 'renders the a_to_z template' do
      expect(response).to render_template('a_to_z')
    end
  end

  describe 'GET lookup_by_letters' do
    context 'it returns multiple results' do
      before(:each) do
        get :lookup_by_letters, params: { letters: 'labour' }
      end

      it 'should have a response with http status ok (200)' do
        expect(response).to have_http_status(200)
      end

      it 'assigns @parties and @letters' do
        assigns(:parties).each do |party|
          expect(party).to be_a(Grom::Node)
          expect(party.type).to eq('https://id.parliament.uk/schema/Party')
        end

        expect(assigns(:letters)).to be_a(Array)
      end

      it 'renders the lookup_by_letters template' do
        expect(response).to render_template('lookup_by_letters')
      end
    end

    context 'it returns a single result' do
      before(:each) do
        get :lookup_by_letters, params: { letters: 'lock' }
      end

      it 'should have a response with http status redirect (302)' do
        expect(response).to have_http_status(302)
      end

      it 'redirects to people/:id' do
        expect(response).to redirect_to(party_path('6zqf0pPb'))
      end
    end
  end

  describe '#data_check' do
    context 'an available data format is requested' do
      methods = [
          {
            route: 'index',
            data_url: "#{ENV['PARLIAMENT_BASE_URL']}/party_index"
          },
          {
            route: 'current',
            data_url: "#{ENV['PARLIAMENT_BASE_URL']}/party_current"
          },
          {
            route: 'letters',
            parameters: { letter: 'l' },
            data_url: "#{ENV['PARLIAMENT_BASE_URL']}/party_by_initial?initial=l"
          },
          {
            route: 'a_to_z',
            data_url: "#{ENV['PARLIAMENT_BASE_URL']}/party_a_to_z"
          },
          {
            route: 'lookup_by_letters',
            parameters: { letters: 'labour' },
            data_url: "#{ENV['PARLIAMENT_BASE_URL']}/party_by_substring?substring=labour"
          }
        ]

      before(:each) do
        headers = { 'Accept' => 'application/rdf+xml' }
        request.headers.merge(headers)
      end

      it 'should have a response with http status redirect (302)' do
        methods.each do |method|
          if method.include?(:parameters)
            get method[:route].to_sym, params: method[:parameters]
          else
            get method[:route].to_sym
          end
          expect(response).to have_http_status(302)
        end
      end

      it 'redirects to the data service' do
        methods.each do |method|
          if method.include?(:parameters)
            get method[:route].to_sym, params: method[:parameters]
          else
            get method[:route].to_sym
          end
          expect(response).to redirect_to(method[:data_url])
        end
      end

    end
  end

end
