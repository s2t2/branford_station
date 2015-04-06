class FeedHostsController < ApplicationController
  def index
    @hosts = FeedHost.all
  end

  def show
    @host = FeedHost.find(params[:id])
  end
end
