# frozen_string_literal: true

# TODO: consider returning paths or urls
json.id artifact.id
json.user artifact.user.username
json.content_type artifact.content_type
json.created_at artifact.created_at.to_formatted_s(:default)
json.updated_at artifact.updated_at.to_formatted_s(:default)
