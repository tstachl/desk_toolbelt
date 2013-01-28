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
    system('foreman start -f config/environments/Procfile.dev -d ./ -c')
  end
  
  desc 'start the test environment'
  task :test do |t, args|
    system('guard start -d -G config/environments/Guardfile.test -i')
  end
  
  desc 'export by id, this is only for tests'
  task :export, [:id] => :environment do |t, args|
    Export.run args[:id]
  end
end