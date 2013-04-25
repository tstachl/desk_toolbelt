class ImportJob < Struct.new(:id)
  def perform
    Import.run self.id
  end
  
  def before(job)
    import = Import.find self.id
    ImportMailer.import_started_email({
      email: import.auth.user.email,
      name: import.auth.user.name
    }).deliver
  end
  
  def success(job)
    import = Import.find self.id
    ImportMailer.import_finished_email({
      email: import.auth.user.email,
      name: import.auth.user.name
    }).deliver
    
    import.destroy if import.type == 'Import::Migration'
  end
  
  def error(job, exception)
    import = Import.find self.id
    ImportMailer.import_failed_email({
      email: import.auth.user.email,
      name: import.auth.user.name
    }).deliver
    
    import.destroy if import.type == 'Import::Migration'
    Delayed::Job.find(self).destroy
  end
end