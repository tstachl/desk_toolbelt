module ApplicationHelper
  def flash_messages
    f_names = [:warning, :error, :success, :info]
    flash.collect do |message|
      if f_names.include?(message[0].to_sym)
        """
        <div class=\"row\">
          <div class=\"span12\">
            <div class=\"alert alert-block alert-#{message[0]}\">
              <a class=\"close\" data-dismiss=\"alert\" href=\"#\">x</a>
              <h4>#{message[0].to_s.titleize}!</h4>
              #{message[1]}
            </div>
          </div>
        </div>
        """
      end
    end.join.html_safe
  end
  
  def icon(icon, text = '', white = false)
    "<i class=\"icon-#{icon} #{white ? 'icon-white' : ''}\"></i> #{text}".html_safe
  end
  
  def controller_class
    "#{params[:controller]}-#{params[:action]}"
  end
end
