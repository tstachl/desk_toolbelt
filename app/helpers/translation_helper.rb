module TranslationHelper
  def html_decode(string)
    coder = HTMLEntities.new
    coder.decode(string).html_safe
  end
end