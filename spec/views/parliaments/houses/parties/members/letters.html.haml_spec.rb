require 'rails_helper'

RSpec.describe 'parliaments/houses/parties/members/letters', vcr: true do
  before do
    assign(:people, [])
    assign(:parliament, double(:parliament, date_range: '2015 to 2017', graph_id: 'd7b0ec7n'))
    assign(:party, double(:party, name: 'Conservative', graph_id: 'b6tdch4k'))
    assign(:letters, [])
    assign(:house, double(:house, graph_id: 'zxcv9786'))
    assign(:letters, 'P')
    controller.params = { letter: 'p' }
    allow(Parliament::Utils::Helpers::HousesHelper).to receive(:commons?).and_return(true)
  end

  context 'header' do
    context 'MPs' do
      before do
        render
      end

      it 'will render the correct header' do
        expect(rendered).to match(/Conservative - MPs/)
      end
    end

    context 'Lords' do
      before do
        allow(Parliament::Utils::Helpers::HousesHelper).to receive(:commons?).and_return(false)
        render
      end

      it 'will render the correct header' do
        expect(rendered).to match(/Conservative - Lords/)
      end
    end

    before do
      render
    end

    it 'will render the correct date range' do
      expect(rendered).to match(/2015 to 2017 Parliament/)
    end

    it 'will render the correct letters' do
      expect(rendered).to match(/A to Z - showing results for P/)
    end

    it 'will render pugin/components/_navigation-letter partial' do
      expect(response).to render_template(partial: 'pugin/components/_navigation-letter')
    end
  end

end
