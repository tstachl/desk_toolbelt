class MigrationsController < ApplicationController
  skip_before_filter :require_login, only: [:desk]
  skip_after_filter :store_return_to, only: [:select]
  
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
    # do we have the zendesk authentication?
    unless session[:zendesk]
      flash[:error] = 'You need to authenticate with Zendesk.'
      return redirect_to action: :zendesk
    end
  
    # all set we can create a new migration
    @migration = Export::Migration.new
    @migration.from = Auth.find session[:zendesk]
    @migration.auth = current_auth
  
    # make sure we redirect to finish after creating the migration
    session[:return_to] = migrations_finish_path
  end
  
  def finish; end
  
  def create
    @migration = Export::Migration.new params[:export_migration]
    @migration.from = Auth.find session[:zendesk]
    @migration.auth = current_auth
    
    @migration.valid?
    Rails.logger.debug(@migration.errors.full_messages)
    
    if @migration.save
      flash[:success] = "New migration job has been created."
      redirect_back action: :finish
    else
      flash[:error] = "The migration job couldn't be created, please review your information and try again."
      redirect_to action: :select
    end
  end
end