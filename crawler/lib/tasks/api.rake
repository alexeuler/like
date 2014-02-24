dir=File.expand_path("../", File.dirname(__FILE__))

namespace :api do
  desc "starts api daemon"
  task :start do
    system "cd #{dir}/crawler/api && ruby daemon.rb start"
  end

  desc "stops api daemon"
  task :stop do
    system "cd #{dir}/crawler/api && ruby daemon.rb stop"
  end

end