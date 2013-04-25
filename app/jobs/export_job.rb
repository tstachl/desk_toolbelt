class ExportJob < Struct.new(:id)
  def perform
    Export.run self.id
  end

  def before(job)
    export = Export.find self.id
    ExportMailer.export_started_email({
      email: export.auth.user.email,
      name: export.auth.user.name
    }).deliver
  end
  
  def success(job)
    export = Export.find self.id
    ExportMailer.export_finished_email({
      email: export.auth.user.email,
      name: export.auth.user.name
    }).deliver
    
    export.destroy if export.type == 'Export::Migration'
  end
  
  def error(job, exception)
    export = Export.find self.id
    ExportMailer.export_failed_email({
      email: export.auth.user.email,
      name: export.auth.user.name
    }).deliver
    
    export.destroy if export.type == 'Export::Migration'
    Delayed::Job.find(self).destroy
  end
end