module Weather
  module UseCases
    # Use case for searching weather conditions, current, high, low temps
    # for a given zip code or city/state.
    # - Caches the results of external API lookup
    # - does NOT cache the serialized view of results in case view changes
    # - does NOT CACHE API results if there is an error, e.g. API key error or socket error
    # - DOES cache results if the location is not found
    class WeatherSearch
      attr_accessor :api_instance, :report_factory_instance, :location_factory_instance

      RESULT_CACHE_TIME = 1.minute

      def perform(query)
        validate_query(query)

        # Cache successful API results, event if location not found
        # so we don't exhaust our API limits
        key = cache_key(query)
        cached = Rails.cache.exist?(key)
        response = Rails.cache.fetch(key, expires_in: RESULT_CACHE_TIME) do
          begin
            api.search(query)
          rescue Weather::Exceptions::BadLocation
            {}
          end
        end

        report_factory.build_from_hash(response, cached).serialize
      end

      private

      def validate_query(query)
        # make sure we either have a zip code or a postal code
        self.location_factory.build_from_query(query)
      end

      def cache_key(query)
        # make sure we don't make super big cache keys
        # based on large search queries
        "#{Digest::SHA1.hexdigest(query)}/conditions"
      end

      def location_factory
        self.location_factory_instance ||= Weather::Factories::Location.new
      end

      def report_factory
        self.report_factory_instance ||= Weather::Factories::Report.new
      end

      def api
        self.api_instance ||= Weather::Services::WeatherApis::WeatherApiCom.new(api_key)
      end

      def api_key
        Rails.application.credentials.weather_api_com_api_key
      end
    end
  end
end
