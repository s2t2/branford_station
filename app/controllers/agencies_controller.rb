class AgenciesController < ApplicationController
  #Lists all transit agencies.
  def index
    @agencies = Agency.all.sort_by{|a| a.name} #Agency.all.order("host_name").order("feed_name").order("name")
  end

  #Lists all train stations serviced by a given agency.
  def show
    #todo: assign universal identifiers
    #agency_abbreviation = params[:agency_abbreviation]
    #raise "UNEXPECTED IDENTIFIER" if agency_abbreviation.include?(";") || agency_abbreviation.class != String

    agency_id = params[:agency_id]
    @agency = Agency.all.find{|a| a[:id] == agency_id.to_i} #Agency.where(:abbreviation => agency_abbreviation)
  end
end
