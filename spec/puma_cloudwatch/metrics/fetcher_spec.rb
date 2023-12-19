RSpec.describe PumaCloudwatch::Metrics::Fetcher do
  subject(:fetcher) { described_class.new(control_url: 'unix://', control_auth_token: '') }

  describe "fetcher" do
    it "call" do
      fake_data = {"fake" => "data"}
      json_data = JSON.dump(fake_data)
      allow(Socket).to receive(:unix).and_return(json_data)

      stats = fetcher.call
      expect(stats).to eq(fake_data)
    end
  end
end
