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
      Auth.from_omniauth request.env['omniauth.auth'], current_auth.user
      flash[:success] = 'Authentication has been saved.'
      redirect_back action: :index
    else
      current_auth Auth.login_omniauth request.env['omniauth.auth']
      flash[:success] = 'You are now logged in.'
      redirect_to controller: :sessions, action: :index
    end
  rescue AuthError => e
    redirect_to action: :failure, message: e.message
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
    current_auth Auth.where(id: params[:id], user_id: current_auth.user.id).first
    flash[:info] = "Your context has been changed to <strong>#{current_auth.site.name_clean}</strong>."
    redirect_back action: :index
  end
end
