class FeedHost < ActiveRecord::Base
  has_many :feeds, :foreign_key => :host_id, :inverse_of => :host

  # This method is only valid because FeedConsumer only persists hosts from http scheme, and strips "http" from the name before storing. Alternatively, store the fully-qualified name including the "http", and change the shortcut method below to #name, which should strip the "http"...
  def url
    "http://#{name}"
  end

  def feed_names
    feeds.map{|f| f.name}.uniq.sort.join(", ")
  end

  def feed_agencies
    feeds.map {|f|
      f.versions.map {|fv|
        fv.agencies.map {|a|
          a.name
        }
      }
    }.flatten.uniq.sort.join(", ")
  end
end
