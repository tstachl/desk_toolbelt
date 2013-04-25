class ImportJob < Struct.new(:id)
  def perform
    Import.run self.id
  end
  
  def before(job)
    import = Import.find self.id
    ImportMailer.import_started_email({
      email: import.auth.user.email,
      name: import.auth.user.name
    })
  end
  
  def success(job)
    import = Import.find self.id
    ImportMailer.import_finished_email({
      email: import.auth.user.email,
      name: import.auth.user.name
    })
  end
  
  def error(job, exception)
    import = Import.find self.id
    ImportMailer.import_failed_email({
      email: import.auth.user.email,
      name: import.auth.user.name
    })
    
    Delayed::Job.find(self).destroy
  end
end