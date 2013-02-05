module ExportsHelper
  def preview_headers
    @result['results'].first[@export.method.to_s.singularize].keys or {}
  end
  
  def preview_values
    @result['results'].map{ |rec|
      rec[@export.method.to_s.singularize].values.map{ |v| Export.tabular_value(v, false, :short) } or {}
    }
  end
  
  def export_filter(filter)
    counter = 0
    html = []
    filter.each_pair do |key, value|
      next if value.blank?
      html.push '<div class="row-fluid">' if counter % 2 == 0
      html.push '<div class="span6"><h5>' + key.titleize + '</h5><p>' + value + '</p></div>'
      html.push '</div>' if counter % 2 == 1
      counter += 1
    end
    html.push '</div>' unless html.last == '</div>'
    html.join.html_safe
  end
end
