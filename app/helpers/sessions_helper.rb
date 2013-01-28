module SessionsHelper
  def username_with_icon
    "#{image_tag(current_auth.user.gravatar, alt: current_auth.user.name, size: '20x20')} #{current_auth.user.name} <small>(#{current_auth.site.name_clean})</small>"
  end
end
