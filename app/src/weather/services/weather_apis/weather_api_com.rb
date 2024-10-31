module Weather
  module Services
    module WeatherApis
      # Weather API available at https://www.weatherapi.com
      # Request/Response Formats https://www.weatherapi.com/docs/
      # - url requires an api key param (?key=)and a search term param (?q=)
      # - limited calls per day
      # - search param q could be a zip code e.g. "20814" or a city like "Bethesda" (service tries to match state/country)
      #   or a city/state like "Bethesda,MD"
      class WeatherApiCom
        BAD_API_KEY_ERROR_CODE = 2008
        ENDPOINT_URL = "http://api.weatherapi.com/v1/forecast.json?key=%{api_key}&q=%{query}"

        attr_accessor :api_key

        def initialize(api_key)
          self.api_key = api_key
        end

        def search(query)
          # fix issue where Washington, D.C. isn't bringing up results
          # needs to be Washington, DC on this API
          query = query.delete(".")

          response, body = get_response(query)

          return response_to_hash(body) if response.success?

          error_code = body.dig("error", "code")

          if error_code == BAD_API_KEY_ERROR_CODE
            raise Weather::Exceptions::BadApiKey
          elsif error_code || !body.key?("location")
            raise Weather::Exceptions::BadLocation
          else
            raise Weather::Exceptions::BadLookup
          end
        end

        private

        def get_response(query)
          url = ENDPOINT_URL % { api_key: api_key, query: query }

          begin
            response = HTTParty.get(url)
            body = JSON.parse(response.body)
          rescue StandardError
            raise Weather::Exceptions::BadApiUrl
          end

          [ response, body ]
        end

        def response_to_hash(response)
          location = response["location"]
          current_temp = response.dig("current", "temp_f")
          high_temp = response.dig("forecast", "forecastday", 0, "day", "maxtemp_f")
          low_temp = response.dig("forecast", "forecastday", 0, "day", "mintemp_f")

          {
            city: location["name"],
            region: location["region"],
            country: location["country"],
            current: current_temp,
            high: high_temp,
            low: low_temp
          }
        end
      end
    end
  end
end
