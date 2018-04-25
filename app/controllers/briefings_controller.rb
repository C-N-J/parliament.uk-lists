class BriefingsController < ApplicationController
  require 'open-uri'

  def index
    @client = ParliamentLdaClient::Request.new('researchbriefings')

    @briefing_response = @client.get({ 'min-date': (Time.zone.now - 1.week).strftime('%Y-%m-%d'), 'max-date': Time.zone.now.strftime('%Y-%m-%d') })

    @briefings = []

    Struct.new('Briefing', :id, :title, :summary, :library, :created, :topic)

    @briefing_response['result']['items'].each do |briefing|
      summary  = briefing.dig('abstract', '_value')
      title    = briefing['title']
      id       = briefing['_about'].scan(/resources\/(\d+)/)[0][0]
      library  = briefing.dig('publisher', 'prefLabel', '_value')
      created  = briefing.dig('created', '_value') || briefing.dig('date', '_value')
      topic    = briefing.dig('topic')&.first&.dig('prefLabel', '_value')
      @briefings << Struct::Briefing.new(id, title, summary, library, created, topic)
    end

    @briefings = @briefings.group_by { |briefing| Date.parse(briefing.created) }
  end
end
