class ImportsController < ApplicationController
  def index
    @imports = current_auth.imports
    @import = Import.new
    respond_to do |format|
      format.json { render json: @imports }
      format.xml { render xml: @imports }
      format.html
    end
  end

  def edit
  end

  def show
    @import = current_auth.imports.find params[:id]
    respond_to do |format|
      format.json { render json: @import }
      format.xml { render xml: @import }
      format.html
    end
  end

  def new
    @import = Import.new
  end

  def create
    @import = Import.new params[:import]
    @import.auth = current_auth
    
    if @import.save
      flash[:success] = "Your import has been created, we'll start importing shortly."
      redirect_back action: :index
    else  
      @imports = current_auth.imports
      flash[:error] = "We are not able to create your import."
      render action: :index
    end
  end

  def update
  end

  def destroy
    @import = current_auth.import.find params[:id]
    unless @import.is_importing
      @import.destroy
      flash[:success] = "The translation and all related information has been deleted."
      redirect_back action: :index
    else
      flash[:info] = "Our worker is currently working on this job, please delete it once we're done."
      redirect_back action: :index
    end
  rescue => err
    flash[:error] = err
    redirect_back action: :index
  end
end
