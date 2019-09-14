RSpec.describe PumaCloudwatch::Metrics::Fetcher do
  subject(:fetcher) { described_class.new(control_url: '', control_auth_token: '') }

  describe "fetcher" do
    it "call" do
      json_data = JSON.dump({fake: "data"})
      allow(Socket).to receive(:unix).and_return(json_data)

      stats = fetcher.call
      expect(stats).to be_a(Hash)
    end
  end
end
