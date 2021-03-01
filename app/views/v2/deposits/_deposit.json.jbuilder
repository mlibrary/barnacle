# frozen_string_literal: true

# TODO: consider returning paths or urls
json.id deposit.id
json.artifact deposit.artifact_id
json.user deposit.user.username
json.status deposit.status
json.upload_link deposit.upload_link
json.created_at deposit.created_at.to_formatted_s(:default)
json.updated_at deposit.updated_at.to_formatted_s(:default)
