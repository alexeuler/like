module Crawler
  module Logging
    def log(message = "")
      puts "#{Time.now.strftime('%H - %M - %S # %L')} : #{message}. Thread : #{Thread.current[:number]}"
    end
  end
end