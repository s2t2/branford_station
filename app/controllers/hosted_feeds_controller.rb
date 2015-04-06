class HostedFeedsController < ApplicationController
  include TwitterBootstrapHelper

  def index
    host_id = params[:host_id]
    redirect_to host_path(host_id)
  end

  def show
    host_id = params[:host_id]
    feed_id = params[:feed_id]
    @feed = Feed.where(:host_id => host_id, :id => feed_id).first
  end

  def show_latest
    feed_id = params[:feed_id]
    feed = Feed.find(feed_id)
    latest_version = feed.latest_version
    redirect_to hosted_feed_version_path(:version_id => latest_version.id)
  end
end
