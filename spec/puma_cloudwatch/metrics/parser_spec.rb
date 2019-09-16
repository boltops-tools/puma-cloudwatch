RSpec.describe PumaCloudwatch::Metrics::Parser do
  subject(:parser) { described_class.new(data) }

  context "single mode" do
    let(:data) do
      {"started_at"=>"2019-09-16T19:20:12Z",
       "backlog"=>0,
       "running"=>16,
       "pool_capacity"=>8,
       "max_threads"=>16}
    end

    it "call" do
      results = parser.call
      expect(results).to be_a(Array)
      expect(results).to eq(
        [{:backlog=>[0],
          :running=>[16],
          :pool_capacity=>[8],
          :max_threads=>[16]}]
      )
    end
  end

  context "cluster mode" do
    # initial data does not yet have last_status filled out
    context "last_status initially empty" do
      let(:data) {
        {"started_at"=>"2019-09-14T17:18:54Z",
         "workers"=>2,
         "phase"=>0,
         "booted_workers"=>2,
         "old_workers"=>0,
         "worker_status"=>
          [{"started_at"=>"2019-09-14T17:18:54Z",
            "pid"=>17170,
            "index"=>0,
            "phase"=>0,
            "booted"=>true,
            "last_checkin"=>"2019-09-14T17:18:54Z",
            "last_status"=>{}},
           {"started_at"=>"2019-09-14T17:18:54Z",
            "pid"=>17184,
            "index"=>1,
            "phase"=>0,
            "booted"=>true,
            "last_checkin"=>"2019-09-14T17:18:54Z",
            "last_status"=>{}}]}
      }

      it "call" do
        results = parser.call
        expect(results).to be_empty
      end
    end

    context "last_status filled out" do
      let(:data) {
        {"started_at"=>"2019-09-16T16:12:11Z",
           "workers"=>2,
           "phase"=>0,
           "booted_workers"=>2,
           "old_workers"=>0,
           "worker_status"=>
            [{"started_at"=>"2019-09-16T16:12:11Z",
              "pid"=>19832,
              "index"=>0,
              "phase"=>0,
              "booted"=>true,
              "last_checkin"=>"2019-09-16T16:12:41Z",
              "last_status"=>
               {"backlog"=>0, "running"=>1, "pool_capacity"=>16, "max_threads"=>16}},
             {"started_at"=>"2019-09-16T16:12:11Z",
              "pid"=>19836,
              "index"=>1,
              "phase"=>0,
              "booted"=>true,
              "last_checkin"=>"2019-09-16T16:12:41Z",
              "last_status"=>
               {"backlog"=>0,
                "running"=>16,
                "pool_capacity"=>8,
                "max_threads"=>16}}]}

      }

      it "call" do
        results = parser.call
        expect(results).to be_a(Array)
        expect(results).to eq(
          [{:backlog=>[0, 0],
            :running=>[1, 16],
            :pool_capacity=>[16, 8],
            :max_threads=>[16, 16]}]
        )
      end
    end
  end
end
