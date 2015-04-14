class StopVersionsController < ApplicationController
  def index
    version_id = params[:version_id]
    @stops = StopVersion.where(:version_id => version_id)
  end

  #def show
  #
  #end
end
