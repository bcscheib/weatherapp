module Weather
  module Factories
    class Report
      attr_accessor :location_factory_instance

      def build_from_hash(conditions, cached = false)
        location = location_factory.build_from_hash(conditions)

        Weather::Domains::Report.new(location, conditions[:current], conditions[:high], conditions[:low], cached)
      end

      private

      def location_factory
        self.location_factory_instance ||= Weather::Factories::Location.new
      end
    end
  end
end
