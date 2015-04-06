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
end
