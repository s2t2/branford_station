class GoogleTransitDataFeedPublicFeed < ActiveRecord::Base

  belongs_to :agency, :class_name => GoogleTransitDataFeedPublicFeedAgency

  #def self.consumable
  #  url.ends_with?(".zip")
  #end
end
