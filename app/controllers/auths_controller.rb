class AuthsController < ApplicationController
  skip_before_filter :require_login, only: [:create]

  def index
    @auths = current_auth.user.auths
    respond_to do |format|
      format.json { render json: @auths }
      format.xml { render xml: @auths }
      format.html
    end
  end

  def edit
  end

  def show
  end
  
  def new
    @auth = Auth.new
    @auth.build_site
  end

  def create
    if logged_in?
      @auth = Auth.from_omniauth request.env['omniauth.auth'], current_auth.user

      # make sure we have the zendesk auth
      if session[:return_to] =~ /\/migrations\/zendesk/
        return redirect_to migrations_zendesk_path(auth_id: @auth.id)
      end
      
      flash[:success] = 'Authentication has been saved.'
      redirect_back action: :index
    else
      redirect = session[:return_to] =~ /\/migrations\/desk/ ? migrations_zendesk_path : root_path
      reset_session
      current_auth Auth.login_omniauth request.env['omniauth.auth']
      flash[:success] = 'You are now logged in.'
      redirect_to redirect
    end
  rescue AuthError => e
    redirect_to controller: :sessions, action: :failure, message: e.message
  end

  def update
  end

  def destroy
    user = current_auth.user
    auths = Auth.destroy_all(id: params[:id], user_id: user.id)
    
    respond_to do |format|
      format.json { render json: { success: true, auths: auths } }
      format.xml { render xml: { success: true, auths: auths } }
      format.html do
        unless Auth.exists?(current_auth.id)
          if user.auths(true).empty?
            flash[:info] = 'Your last authorization has been deleted. You have been logged out.'
            return redirect_to login_path
          else
            current_auth user.auths.first
            flash[:info] = "Your context has been changed to <strong>#{current_auth.site.name_clean}</strong>."
          end
        end

        flash[:success] = 'Authorization has been deleted.'
        redirect_back action: :index
      end
    end
  end

  def change
    current_auth current_auth.user.auths.find params[:id]
    flash[:info] = "Your context has been changed to <strong>#{current_auth.site.name_clean}</strong>."
    redirect_back action: :index
  end
end
