class Logger
  def format_message(level, time, progname, msg)
    "#{time.to_s(:db)} #{level} -- #{msg}\n"
  end
end

if defined?(Rails) && (Rails.env == 'development')
  Rails.logger = Logger.new(STDOUT)
end

namespace :dev do
  desc 'start the development server'
  task :start do |t, args|
    system('foreman start -f config/environments/Procfile.dev -d ./ -c -e config/environments/development.env')
  end
  
  namespace :test do
    desc 'run controller tests'
    task :controllers do
      system('foreman run -e config/environments/test.env bundle exec rake spec:controllers')
    end
    
    desc 'run model tests'
    task :models do
      system('foreman run -e config/environments/test.env bundle exec rake spec:models')
    end
  end
  
  desc 'run all tests'
  task :test do
    system('foreman run -e config/environments/test.env bundle exec rake spec')
  end
  
  desc 'export by id, this is only for tests'
  task :export, [:id] => :environment do |t, args|
    Export.run args[:id]
  end
end