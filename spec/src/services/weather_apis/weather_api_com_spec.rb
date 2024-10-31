require 'rails_helper'

describe Weather::Services::WeatherApis::WeatherApiCom do
  subject { Weather::Services::WeatherApis::WeatherApiCom.new('123') }

  describe "#search" do
    context "when we get a successful response" do
      it "should return the conditions when json is valid" do
        mock_response = double(body: '{"location": {"name": "memphis", "region": "tn", "country": "us"}, "current": {"temp_f": "80"}}')
        allow(mock_response).to receive(:success?).and_return(true)
        allow(HTTParty).to receive(:get).and_return(mock_response)
        conditions = subject.search("memphis,tn")

        expect(conditions).to eql({ city: "memphis", region: "tn", country: "us", current: "80", high: nil, low: nil})
        expect(HTTParty).to have_received(:get).once().with("http://api.weatherapi.com/v1/forecast.json?key=123&q=memphis,tn")
      end

      it "should raise an exception when the json is malformed" do
        mock_response = double(body: '{malformedjsonhere}')
        allow(HTTParty).to receive(:get).and_return(mock_response)

        expect {  subject.search("memphis,tn") }.to raise_error(Weather::Exceptions::BadApiUrl)
      end
    end

    context "when we get error responses" do
      it "should raise an exception when we have trouble connecting" do
        allow(HTTParty).to receive(:get).and_raise(StandardError)

        expect {  subject.search("memphis,tn") }.to raise_error(Weather::Exceptions::BadApiUrl)
      end

      it "should raise a bad api key exception" do
        mock_response = double(success?: false, forbidden?: true, body: '{"error": {"code": 2008}}')
        allow(HTTParty).to receive(:get).and_return(mock_response)

        expect {  subject.search("memphis,tn") }.to raise_error(Weather::Exceptions::BadApiKey)
      end

      it "should raise a bad location exception with an error key" do
        mock_response = double(success?: false, forbidden?: false, body: '{"error": {"code": 1111}}')
        allow(HTTParty).to receive(:get).and_return(mock_response)

        expect {  subject.search("memphis,tn") }.to raise_error(Weather::Exceptions::BadLocation)
      end

      it "should raise a bad location exception with no location key" do
        mock_response = double(success?: false, forbidden?: false, body: '{}')
        allow(HTTParty).to receive(:get).and_return(mock_response)

        expect {  subject.search("memphis,tn") }.to raise_error(Weather::Exceptions::BadLocation)
      end

      it "should raise a bad lookup otherwise" do
        mock_response = double(success?: false, forbidden?: false, body: '{"location": {}}')
        allow(HTTParty).to receive(:get).and_return(mock_response)

        expect {  subject.search("memphis,tn") }.to raise_error(Weather::Exceptions::BadLookup)
      end
    end
  end
end