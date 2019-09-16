RSpec.describe PumaCloudwatch::Metrics::Sender do
  subject(:sender) do
    sender = described_class.new(metrics)
    allow(sender).to receive(:cloudwatch).and_return(cloudwatch)
    sender
  end
  let(:cloudwatch) { double(:null).as_null_object }

  context "clustered" do
    let(:workers) { 2 }

    context "metrics filled out" do
      let(:metrics) {
        [{:backlog=>[0, 0],
        :running=>[0, 0],
        :pool_capacity=>[16, 16],
        :max_threads=>[16, 16]}]
      }

      it "metric_data" do
        data = sender.metric_data
        expect(data).to eq(
          [{:metric_name=>"backlog",
            :dimensions=>[{:name=>"App", :value=>"puma"}],
            :statistic_values=>{:sample_count=>2, :sum=>0, :minimum=>0, :maximum=>0}},
           {:metric_name=>"running",
            :dimensions=>[{:name=>"App", :value=>"puma"}],
            :statistic_values=>{:sample_count=>2, :sum=>0, :minimum=>0, :maximum=>0}},
           {:metric_name=>"pool_capacity",
            :dimensions=>[{:name=>"App", :value=>"puma"}],
            :statistic_values=>{:sample_count=>2, :sum=>32, :minimum=>16, :maximum=>16}},
           {:metric_name=>"max_threads",
            :dimensions=>[{:name=>"App", :value=>"puma"}],
            :statistic_values=>{:sample_count=>2, :sum=>32, :minimum=>16, :maximum=>16}}]
        )
      end

      it "call" do
        allow(cloudwatch).to receive(:put_metric_data)
        sender.call
        expect(cloudwatch).to have_received(:put_metric_data)
      end
    end
  end
end
