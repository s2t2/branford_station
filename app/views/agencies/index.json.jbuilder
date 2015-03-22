json.array! @agencies do |agency|
  json.identifier agency.id
  json.name agency.name
  json.url agency.url
  json.timezone agency.timezone
  json.lang agency.lang
  json.phone agency.phone
  json.fare_url agency.fare_url
end
