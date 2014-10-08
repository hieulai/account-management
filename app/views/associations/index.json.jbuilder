json.array!(@associations) do |association|
  json.extract! association, :id, :user_id, :contact_id
  json.url association_url(association, format: :json)
end
