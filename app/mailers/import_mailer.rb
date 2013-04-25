class ImportMailer < ActionMailer::Base
  default from: "tom@desk.com"
  
  def import_started_email(hash)
    @name = hash[:name]
    mail(to: hash[:email], subject: 'IMPORT - We just started the import')
  end
  
  def import_finished_email(hash)
    @name = hash[:name]
    mail(to: hash[:email], subject: 'IMPORT - Your import is finished')
  end
  
  def import_failed_email(hash)
    @name = hash[:name]
    mail(to: hash[:email], subject: 'IMPORT FAILED - Something went wrong during your import')
  end
end
