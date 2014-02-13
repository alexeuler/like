#require "crawler/api/autoload"
require "net/http"

describe "Api" do
  it "receives requests and returns responses" do
    Net::Http.stub(:get_response)
  end
end
