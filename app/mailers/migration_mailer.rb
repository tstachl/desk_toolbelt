class MigrationMailer < ActionMailer::Base
  default from: "tom@desk.com"
  
  def starting_import_email(export_id)
    export = Export.find export_id
    @user = export.auth.user
    mail(to: @user.email, subject: "MIGRATION - Starting the import now")
  end
  
  def create_import_failure_email(export_id)
    export = Export.find export_id
    @user = export.auth.user
    mail(to: @user.email, subject: "MIGRATION - ERROR - Creating an import")
  end
end
