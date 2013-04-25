class ExportMailer < ActionMailer::Base
  default from: "tom@desk.com"
  
  def export_started_email(hash)
    @name = hash[:name]
    mail(to: hash[:email], subject: 'EXPORT - We just started the export')
  end
  
  def export_finished_email(hash)
    @name = hash[:name]
    mail(to: hash[:email], subject: 'EXPORT - Your export is ready')
  end
  
  def export_failed_email(hash)
    @name = hash[:name]
    mail(to: hash[:email], subject: 'EXPORT FAILED - Something went wrong during your export')
  end
end