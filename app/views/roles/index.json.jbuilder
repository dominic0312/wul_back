json.array!(@roles) do |role|
  json.extract! role, :role_name
  json.url role_url(role, format: :json)
end
