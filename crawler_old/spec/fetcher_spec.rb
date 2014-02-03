require "fetcher"
describe Fetcher do
  let (:manager) {double("manager")}
  let (:fetcher) {Fetcher.new manager: manager}

  describe "#start" do
    it "starts a new fetcher" do
      continue=true
      manager.should_receive(:get_work).at_least(:once) do
        continue ? "work_id" : nil
      end
      fetcher.wrapped_object.should_receive(:fetch).at_least(:once).and_return(["new_work_id_1", "new_work_id_2"])
      manager.should_receive(:push).with(["new_work_id_1", "new_work_id_2"]).at_least(:once)
      manager.should_receive(:done).with("work_id").at_least(:once)
      manager.should_receive(:full_frontier?).at_least(:once)
      fetcher.async.start
      sleep 0.05
      continue=false
      sleep 0.05
    end
  end

end
