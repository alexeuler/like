desc "runs the server on localhost:9292 for token management"
task :tokens do
  dir=File.expand_path("../",File.dirname(__FILE__))
  load "#{dir}/crawler/api/tokens/config.ru"
end