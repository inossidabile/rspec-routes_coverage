namespace :spec do
  namespace :requests do
    desc 'run requests specs with counting of untested routes'
    task :with_coverage do
      files = Dir["spec/requests/**/*_spec.rb"].map{|f| "./"+f}
      ENV["WITH_ROUTES_COVERAGE"] = 'true'
      exec "ruby -S rspec #{files.join ' '}"
    end
  end
end