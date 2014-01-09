dir=File.expand_path(File.dirname(__FILE__))

namespace :crawler do
  task :spec do
    system "cd #{dir}/crawler && rspec -c --format documentation" 
  end

  namespace :api do
    task :start do
      system "cd #{dir}/crawler/lib/api && ruby daemon.rb start && cd #{dir}"
    end

    task :stop do
      system "cd #{dir}/crawler/lib/api && ruby daemon.rb stop && cd #{dir}"
    end

    task :restart do
      system "cd #{dir}/crawler/lib/api && ruby daemon.rb restart && cd #{dir}"
    end

    task :benchmark, :file_name do |t, args|
      Rake::Task["crawler:api:restart"].invoke
      sleep(2)
      require "#{dir}/crawler/lib/api/benchmark/#{args.file_name}"
      Rake::Task["crawler:api:stop"].invoke
    end

  end
end
