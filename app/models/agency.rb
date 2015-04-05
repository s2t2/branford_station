class Agency
  def self.all
    Feed.all.map{|f| f.versions.latest.try(:agencies)}.flatten
  end
end
