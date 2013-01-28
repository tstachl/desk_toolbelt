module ExportsHelper
  def preview_headers
    @result['results'].first[@export.method.to_s.singularize].keys or {}
  end
  
  def preview_values
    @result['results'].map{ |rec|
      rec[@export.method.to_s.singularize].values.map{ |v| Export.tabular_value(v, false, :short) } or {}
    }
  end
end
