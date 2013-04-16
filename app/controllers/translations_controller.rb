class TranslationsController < ApplicationController
  def index
    @translations = Export::Knowledge::Translation.where('auth_id = ?', current_auth.id)
    @translation = Export::Knowledge::Translation.new
    respond_to do |format|
      format.json { render json: @translations }
      format.xml { render xml: @translations }
      format.html
    end
  end
  
  def edit; end
  def show; end
  def new; end
  
  def create
    @translation = Export::Knowledge::Translation.new params[:export_knowledge_translation]
    @translation.auth = current_auth
    
    if @translation.save
      flash[:success] = "Your translation has been created, we'll start exporting your Knowledge Base shortly."
      redirect_back action: :index
    else
      @translations = Export::Knowledge::Translation.where('auth_id = ?', current_auth.id)
      flash[:error] = "We are not able to create your translation."
      render action: :index
    end
  end
  
  def update; end
  def destroy; end
end