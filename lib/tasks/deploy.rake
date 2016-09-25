desc 'Series of post deploy scripts'
task :postdeploy do
  Rake::Task["db:migrate"].invoke
  Rake::Task["db:seed"].invoke

  Rake::Task["db:demo"].invoke if ENV["DEPLOY_DEMO"] == "true"

end