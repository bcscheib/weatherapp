class WeatherController < ApplicationController
  def index
    @query = search_query
    @weather = {}

    if !@query.blank?
      begin
        @weather = weather_search.perform(@query)
      rescue Weather::Exceptions::BadLocation
        @error = "Woops, can't find that location! #{@query}"
      rescue Weather::Exceptions::BadLocationFormat
        @error = "Woops, please search for a US Zip code (e.g. 20814) or city/state e.g. (\"Bethesda, MD\")!"
      rescue Weather::Exceptions::BadLookup
        @error = "Woops, having trouble accessing the site, try again."
      rescue Weather::Exceptions::BadApiUrl
        @error = "Woops, the API url for gathering data is bad or unreachable! Check the URL and API key."
      rescue Weather::Exceptions::BadApiKey
        @error = "Woops, the API key for gathering data is expired!"
      end
    end

    render :index
  end

  private

  def weather_search
    Weather::UseCases::WeatherSearch.new
  end

  def search_query
    params.fetch(:query, "").strip
  end
end
