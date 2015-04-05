class AgenciesController < ApplicationController
  #Lists all transit agencies.
  def index
    @agencies = Agency.all.sort_by{|a| a.feed_name}.sort_by{|a| a.name} #Agency.all.order("host_name").order("feed_name").order("name")
  end

  #Lists all train stations serviced by a given agency.
  def show
    agency_abbreviation = params[:agency_abbreviation]
    raise "UNEXPECTED IDENTIFIER" if agency_abbreviation.include?(";") || agency_abbreviation.class != String

    #binding.pry

    @agency = Agency.all.select{|a| a.abbreviation == agency_abbreviation}.sort_by{|a| a.agency_abbreviation} #Agency.where(:abbreviation => agency_abbreviation)
  end
end
