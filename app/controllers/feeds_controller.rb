class FeedsController < ApplicationController
  before_action :set_feed, only: [:show, :edit, :update, :destroy]

  # GET /feeds
  # GET /feeds.json
  def index
    @feeds = Feed.all
  end

  # GET /feeds/1
  # GET /feeds/1.json
  def show
  end

  # GET /feeds/new
  def new
    @feed = Feed.new
  end

  # GET /feeds/1/edit
  def edit
  end

  # POST /feeds
  # POST /feeds.json
  def create
    source_url = feed_params["source_url"]

    uri = URI.parse(source_url)
    unless uri.class == URI::HTTP
      flash[:danger] = "Invalid source_url. It should start with 'http://' like 'http://www.myhost.com/my_transit.zip'."
      redirect_to new_feed_path
    else

      # Create host.

      host_name = uri.host
      host = FeedHost.where(:name => host_name).first_or_create

      feed_name = uri.path.split("/").last
      unless feed_name.is_a?(String) && feed_name.ends_with?(".zip")
        flash[:danger] = "Invalid source_url. After the host, it should contain a file name ending with '.zip' like 'http://www.myhost.com/my_transit.zip'."
        redirect_to new_feed_path
      else

        # Create feed.

        @feed = Feed.where(
          :source_url => source_url,
          :host_id => host.id
        ).first_or_initialize
        @feed.update_attributes(:name => feed_name)

        respond_to do |format|
          if @feed.save
            format.html {
              flash[:success] = 'Feed was successfully created.'
              redirect_to @feed
            }
            format.json { render :show, status: :created, location: @feed }
          else
            format.html { render :new }
            format.json { render json: @feed.errors, status: :unprocessable_entity }
          end
        end

      end
    end
  end

  # PATCH/PUT /feeds/1
  # PATCH/PUT /feeds/1.json
  def update
    respond_to do |format|
      if @feed.update(feed_params)
        format.html {
          flash[:success] = 'Feed was successfully updated.'
          redirect_to @feed
        }
        format.json { render :show, status: :ok, location: @feed }
      else
        format.html { render :edit }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feeds/1
  # DELETE /feeds/1.json
  def destroy
    @feed.destroy
    respond_to do |format|
      format.html { redirect_to feeds_url, notice: 'Feed was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feed
      @feed = Feed.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def feed_params
      params.require(:feed).permit(:source_url)
    end
end
