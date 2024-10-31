module Weather
  module Factories
    class Location
      US_ZIP_REGEX = /^\d{5}(-\d{4})?$/
      US_CITY_STATE_REGEX = /([A-Za-z]+(?: [A-Za-z]+)*),\s?([A-Za-z\.]{2})/

      def build_from_query(query)
        return build_from_us_postal_code(query) if query.match(US_ZIP_REGEX)

        city_state_parts = query.scan(US_CITY_STATE_REGEX)

        return build_from_us_city_state(*city_state_parts[0]) unless city_state_parts.empty?

        raise Weather::Exceptions::BadLocationFormat
      end

      def build_from_hash(conditions)
        Weather::Domains::Location.new(conditions[:city], conditions[:region], conditions[:country])
      end

      private

      def build_from_us_postal_code(postal_code)
        Weather::Domains::Location.new(nil, nil, nil, postal_code)
      end

      def build_from_us_city_state(city, state)
        Weather::Domains::Location.new(city, state)
      end
    end
  end
end
