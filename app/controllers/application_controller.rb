class ApplicationController < ActionController::Base
  before_filter :require_login, :render_modal
  after_filter :store_return_to
  
  protect_from_forgery
  
  def current_auth(auth = nil)
    if auth.kind_of?(Auth)
      session[:aid] = auth.id
      @current_auth = auth
    elsif not session[:aid].nil?
      @current_auth ||= Auth.find(session[:aid])
    else
      false
    end
  end
  helper_method :current_auth
  
  # The logged_in? method simply returns true if the user is logged
  # in and false otherwise. It does this by "booleanizing" the
  # current_user method we created previously using a double ! operator.
  # Note that this is not common in Ruby and is discouraged unless you
  # really mean to convert something into true or false.
  def logged_in?
    !!current_auth
  end
  helper_method :logged_in?
  
  def xhr?
    !!request.xhr?
  end
  helper_method :xhr?
 
  private

  def redirect_back(default)
    redirect_to(session[:return_to] || default)
  end

  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this section"
      redirect_to login_path # halts request cycle
    end
  end
  
  def store_return_to
    session[:return_to] = request.url unless request.xhr?
  end
  
  def render_modal
    if xhr?
      self.class.layout 'modal'
    else
      self.class.layout nil
    end
  end
  
  def client
    Desk.client subdomain: current_auth.site.name, oauth_token: current_auth.token, oauth_token_secret: current_auth.secret
  end
end
