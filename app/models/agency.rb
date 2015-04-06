class Agency

  #todo: only get authorized agencies
  def self.all
    Feed.all.map{|f| f.versions.latest.try(:agencies)}.flatten.compact
  end
end
