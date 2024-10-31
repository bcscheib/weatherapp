module Weather
  module Domains
    class Report
      attr_accessor :location, :current_temp, :high_temp, :low_temp, :cached

      def initialize(location = nil, current_temp = nil, high_temp = nil, low_temp = nil, cached = false)
        self.location = location
        self.current_temp = current_temp
        self.high_temp = high_temp
        self.low_temp = low_temp
        self.cached = cached
      end

      def serialize
        {
          found_location: {
            location_name: location.name,
            current_temp: degree_as_temp(current_temp),
            high_temp: degree_as_temp(high_temp),
            low_temp: degree_as_temp(low_temp),
            cached: cached,
          }
        }
      end

      private

      def degree_as_temp(degree)
        "#{degree}F" unless degree.to_s.blank?
      end
    end
  end
end
