class Agency
  def self.all
    Feed.all.map{|f| f.versions.latest.agencies}.flatten
  end
end
