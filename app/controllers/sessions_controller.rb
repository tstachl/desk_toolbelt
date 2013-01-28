class SessionsController < ApplicationController
  skip_before_filter :require_login
  
  def index; end
  
  def new
    if session[:aid]
      flash[:info] = 'Logged In'
      redirect_to action: :index
    end
  end

  def destroy
    session[:aid] = @current_auth = nil
    flash[:info] = 'You have been logged out.'
    redirect_to login_path
  end

  def failure
    flash[:error] = params[:message]
    redirect_to login_path
  end
end
