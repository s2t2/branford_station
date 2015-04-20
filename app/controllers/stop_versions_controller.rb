class StopVersionsController < ApplicationController
  def index
    version_id = params[:version_id]
    @stops = StopVersion.where(:version_id => version_id)
    #redirect_to hosted_feed_version_path(:version_id => version_id)
  end

  def show
    stop_id = params[:stop_id]
    @stop = StopVersion.find(stop_id)
  end
end
