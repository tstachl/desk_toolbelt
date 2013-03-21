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
    @migration = Migration.new
    @migration.from = Auth.find session[:zendesk]
    @migration.to = current_auth
    
    # make sure we redirect to finish after creating the migration
    session[:return_to] = migrations_finish_path
  end

  # def mapping
  #   from_id, to_id = get_from_to_id
  #   @migration = Migration.new params[:migration]
  #   @migration.from_id = from_id
  #   @migration.to_id = to_id
  # end
  
  def finish; end
  
  # probably needed for the toolbelt interface
  # to have an overview of all mananged migrations
  # def index; end
  
  # probably needed for the toolbelt interface
  # not yet defined if we can edit a migration
  # possible before it is run?!?
  # def edit; end
  
  # probably needed for the toolbelt interface
  # to see details about an migration
  # def show; end
  
  # this should be covered by the wizard
  # but theoretically we should be able to create
  # a new migration from the toolbelt interface
  def new; end
  
  # this method creates a new migration
  def create
    from_id, to_id = get_from_to_id
    @migration = Migration.new params[:migration]
    @migration.from_id = from_id
    @migration.to_id = to_id
    
    respond_to do |format|
      if @migration.save
        flash[:success] = "New migration job has been created."
        format.html { redirect_back action: :index }
        format.json { render json: { success: true, migration: @migration } }
        format.xml { render xml: { success: true, migration: @migration } }
      else
        flash.now[:error] = "The migration job couldn't be created, please review your information and try again."
        format.html { render action: :new }
        format.json { render json: { success: false, migration: @migration, message: message } }
        format.xml { render xml: { success: false, migration: @migration, message: message } }
      end
    end
  end

  # this method updates a migration
  # needed ?!?
  # def update; end
  
  # if we want to destroy migrations we should
  # be able too but only if they are not
  # running or are finished.
  # def destroy; end
  
private
  def get_from_to_id
    if params[:migration] && params[:migration].key?(:from_id)
      [params[:migration].delete(:from_id), params[:migration].delete(:to_id)]
    elsif logged_in? and session.key?(:zendesk)
      [Auth.find(session[:zendesk]).id, current_auth.id]
    else
      [nil, nil]
    end
  end
end
