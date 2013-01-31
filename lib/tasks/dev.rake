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
  
  desc 'start the test environment'
  task :test do |t, args|
    system('foreman run -e config/environments/test.env bundle exec rake spec')
  end
  
  desc 'export by id, this is only for tests'
  task :export, [:id] => :environment do |t, args|
    Export.run args[:id]
  end
end