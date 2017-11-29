json.bag_id bag.bag_id
json.user bag.user.username
json.content_type bag.content_type
json.external_id bag.external_id
unless bag.storage_location
  json.upload_link bag.upload_link
end
if @current_user&.admin?
  json.storage_location bag.storage_location
end
json.created_at bag.created_at.to_formatted_s(:default)
json.updated_at bag.updated_at.to_formatted_s(:default)
