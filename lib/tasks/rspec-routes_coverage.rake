namespace :spec do
  namespace :requests do
    desc 'run requests specs with counting of untested routes'
    task :coverage do
      files = Dir["spec/requests/**/*_spec.rb"].map{|f| "./"+f}
      ENV["LIST_ROUTES_COVERAGE"] = 'true'
      exec "ruby -S rspec #{files.join ' '}"
    end
  end
end