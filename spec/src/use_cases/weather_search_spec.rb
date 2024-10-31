require 'rails_helper'

describe Weather::UseCases::WeatherSearch do
  let(:mock_api) { double() }
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  subject { Weather::UseCases::WeatherSearch.new }

  before(:each) do
    allow(Rails.application.credentials).to receive(:weather_api_com_api_key).and_return('123')
    subject.api_instance = mock_api
  end

  describe "#perform" do
    context "when query is valid" do
      it "properly format the api response for zip" do
        allow(mock_api).to receive(:search).and_return(
          {
            city: 'bethesda',
            region: 'md',
            country: 'us',
            current: 10,
            high: 5,
            low: 4,
          }
        )
        report = subject.perform("20814")

        expect(report).to eql(
          {
            found_location: {
              location_name: "bethesda, md",
              current_temp: "10F",
              high_temp: "5F",
              low_temp: "4F",
              cached: false,
            }
          }
        )
      end

      it "properly format the api response for valid city/state" do
        allow(mock_api).to receive(:search).and_return(
          {
            city: 'houston',
            region: 'tx',
            country: 'us',
            current: 10,
            high: 5,
            low: 4,
          }
        )
        report = subject.perform("houston, tx")

        expect(report).to eql(
          {
            found_location: {
              location_name: "houston, tx",
              current_temp: "10F",
              high_temp: "5F",
              low_temp: "4F",
              cached: false,
            }
          }
        )
      end

      it "should only search once because of cache good loc" do
        allow(Rails).to receive(:cache).and_return(memory_store)

        allow(mock_api).to receive(:search).and_return(
          {
            city: 'houston',
            region: 'tx',
            country: 'us',
            current: 10,
            high: 5,
            low: 4,
          }
        )

        report = subject.perform("houston, tx")

        expect(report).to eql(
          {
            found_location: {
              location_name: "houston, tx",
              current_temp: "10F",
              high_temp: "5F",
              low_temp: "4F",
              cached: false,
            }
          }
        )

        report = subject.perform("houston, tx")

        expect(report).to eql(
          {
            found_location: {
              location_name: "houston, tx",
              current_temp: "10F",
              high_temp: "5F",
              low_temp: "4F",
              cached: true,
            }
          }
        )

        expect(mock_api).to have_received(:search).once()
        Rails.cache.clear
      end

      it "should still only search once because of cache with bad loc" do
        allow(Rails).to receive(:cache).and_return(memory_store)

        allow(mock_api).to receive(:search).and_raise(Weather::Exceptions::BadLocation)

        expect { subject.perform("houston, tx") }.to raise_error(Weather::Exceptions::BadLocation)
        expect { subject.perform("houston, tx") }.to raise_error(Weather::Exceptions::BadLocation)

        expect(mock_api).to have_received(:search).once()
        Rails.cache.clear
      end
    end

    context "when query is invalid" do
      it "errors on only a city" do
        expect { subject.perform("bethesda") }.to raise_error(Weather::Exceptions::BadLocationFormat)
      end

      it "errors on a bad length zip" do
        expect { subject.perform("9681") }.to raise_error(Weather::Exceptions::BadLocationFormat)
      end
    end
  end
end
