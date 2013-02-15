module ModelMacro
  def is_valid(obj, field, *args)
    obj.send("#{field.to_s}=", args.first) if args.size == 2
    obj.valid?
    obj.errors.get(field).should_not be_nil

    obj.send("#{field.to_s}=", args.last)
    obj.valid?
    obj.errors.get(field).should be_nil
  end
  
  def export_preview(opts = {}, auth = nil)
    if auth
      export = FactoryGirl.build(:preview_export, auth: auth)
    else
      export = FactoryGirl.build(:preview_export)
    end
    filename = opts.key?(:count) && opts.count == 10 ? 'cases.json' : 'cases_export.json'
    stub_request(:get, "https://devel.desk.com/api/v1/cases.json?#{export.filter.merge(opts).to_query}").
      to_return(status: 200, body: File.new("#{Rails.root}/spec/fixtures/desk/#{filename}"), headers: {content_type: "application/json; charset=utf-8"})
    export
  end
end