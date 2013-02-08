class MigrationsController < ApplicationController
  skip_before_filter :require_login, only: [:desk]
  
  def desk
    reset_session
  end

  def zendesk
    # if the zendesk session is stored we can redirect to select
    if params[:auth_id]
      session[:zendesk] = params[:auth_id]
      flash[:success] = 'Your Zendesk authentication has been saved.'
      return redirect_to action: :select
    end
    
    # clear zendesk in case we are returing one step
    session[:zendesk] = nil
    # if we have a message it can only be an error message
    flash[:error] = params[:message] if params[:message]
    # if we have a success flash it's most likely because we logged in with desk.com
    flash[:success] = 'Your Desk.com authorization has been saved.' if flash[:success]
    
    # if we are still here we need a new auth object
    @auth = Auth.new
    @auth.build_site
  end

  def select
    @migration = Migration.new
  end

  def mapping
  end

  def finish
  end
end
