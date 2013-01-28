class ExportsController < ApplicationController
  def index
    @exports = current_auth.exports
  end

  def edit
  end

  def show
    @results = client.cases
    @debug = @results['results'].first.to_xml skip_instruct: true
  end

  def new
    # what are we exporting? get the type
    key = params[:type].to_sym
    # make sure all arrays are comma separated
    params[key].each{ |k, v| v.is_a?(Array) ? params[key][k] = v.join(',') : params[key][k] = v }
    # create the export with the filter, the method and the auth
    @export = Export.new filter: params[key], method: key.to_s.pluralize.to_sym, auth: current_auth
    
    # get the preview
    @result = @export.preview
  end

  def create
    # parse the filter if json
    if params[:export][:filter].is_a?(String) and params[:export][:filter].is_json?
      params[:export][:filter] = JSON.parse! params[:export][:filter]
    end
    
    @export = Export.new params[:export]
    @export.auth = current_auth
    
    if @export.save
      Export.delay.run @export.id
      flash[:success] = "New export job has been created."
      redirect_back action: :index
    else
      flash[:error] = "The export job couldn't be created, please review your filter settings and try again later."
      redirect_back action: :index
    end
  end

  def update
  end

  def destroy
    @export = Export.find params[:id]
    unless @export.is_exporting
      if @export.destroy
        flash[:success] = "The export job has been deleted."
        redirect_back action: :index
      else
        flash[:error] = "The export job couldn't be deleted. Please try again later."
        redirect_back action: :index
      end
    else
      flash[:info] = "Our worker is currently working on this job, please delete it once we're done."
      redirect_back action: :index
    end
  end
end

=begin
  Export
  
  - auth
  - hash filter
  - method
  - is_exported
  
  rails g model Export method:string filter:text auth:references is_exported:boolean


=end