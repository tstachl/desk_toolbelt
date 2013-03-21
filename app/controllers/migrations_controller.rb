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
    # if we have a success flash it's most likely because we logged in with desk.com
    flash[:success] = 'Your Desk.com authorization has been saved.' if flash[:success]
    
    # if we are still here we need a new auth object
    @auth = Auth.new
    @auth.build_site
  end

  def select
    unless session[:zendesk]
      flash[:error] = 'You need to authenticate with Zendesk.'
      return redirect_to action: :zendesk
    end
    
    @migration = Migration.new
    @migration.from = Auth.find session[:zendesk]
    @migration.to = current_auth
  end

  # def mapping
  #   from_id, to_id = get_from_to_id
  #   @migration = Migration.new params[:migration]
  #   @migration.from_id = from_id
  #   @migration.to_id = to_id
  # end

  def finish
    from_id, to_id = get_from_to_id
    @migration = Migration.new params[:migration]
    @migration.from_id = from_id
    @migration.to_id = to_id
  end
  
private
  def get_from_to_id
    if params[:migration] && params[:migration].key?(:from_id)
      [params[:migration].delete(:from_id), params[:migration].delete(:to_id)]
    else
      [Auth.find(session[:zendesk]).id, current_auth.id]
    end
  end
end
