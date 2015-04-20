json.array!(@feeds) do |feed|
  json.extract! feed, :id, :source_url
  json.url feed_url(feed, format: :json)
end
