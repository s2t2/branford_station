class AgenciesController < ApplicationController
  #Lists all transit agencies.
  def index
    @agencies = Agency.all #.order("host_name").order("feed_name").order("name")
  end

  #Lists all train stations serviced by a given agency.
  def show
    agency_abbreviation = params[:agency_abbreviation]
    raise "UNEXPECTED IDENTIFIER" if agency_abbreviation.include?(";") || agency_abbreviation.class != String

    @agency = Agency.where(:abbreviation => agency_abbreviation)
  end
end
