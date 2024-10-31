module Weather
  module Domains
    class Location
      attr_accessor :city, :region, :country, :postal_code

      def initialize(city = nil, region = nil, country = nil, postal_code = nil)
        self.city = city
        self.region = region
        self.country = country
        self.postal_code = postal_code

        validate
      end

      def name
        [ city, region ].compact.join(", ")
      end

      private

      def validate
        raise Weather::Exceptions::BadLocation if [ city, region, country, postal_code ].none?
      end
    end
  end
end
