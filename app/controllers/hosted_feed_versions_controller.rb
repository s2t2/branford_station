class HostedFeedVersionsController < ApplicationController
  def index
    feed_id = params[:feed_id]
    redirect_to hosted_feed_path(:feed_id => feed_id)
  end

  def show
    version_id = params[:version_id]
    @version = FeedVersion.find(version_id)
  end
end
