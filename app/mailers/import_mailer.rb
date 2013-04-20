class ImportMailer < ActionMailer::Base
  default from: "tom@desk.com"
  
  def notify_email(import_id)
    import = Import.find import_id
    attachments['ImportLogfile.log'] = open(import.logfile.expiring_url(300)).read
    
    @user = import.auth.user
    mail(to: @user.email, subject: "IMPORT - The import is finished")
  end
end
