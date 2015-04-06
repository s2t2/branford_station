class AgencyVersionsController < ApplicationController
  def index
    version_id = params[:version_id]
    redirect_to hosted_feed_version_path(:version_id => version_id)
  end

  def show
    agency_id = params[:agency_id]
    @agency = AgencyVersion.find(agency_id)
  end
end
