module ModelMacro
  def is_valid(obj, field, *args)
    obj.send("#{field.to_s}=", args.first) if args.size == 2
    obj.valid?
    obj.errors.get(field).should_not be_nil

    obj.send("#{field.to_s}=", args.last)
    obj.valid?
    obj.errors.get(field).should be_nil
  end
end