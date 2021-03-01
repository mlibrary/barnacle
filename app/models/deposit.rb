# frozen_string_literal: true

class Deposit < ApplicationRecord

  # Each deposit is created by a single user
  belongs_to :user
  # A deposit is an attempt to append a revision to a single artifact
  belongs_to :artifact

  # TODO Could not get the attributes api to work with a custom type
  enum status: {
    started:   "started",
    canceled:  "cancelled",
    ingesting: "ingesting",
    failed:    "failed",
    completed: "completed"
  }

  validates :user, presence: true
  validates :artifact, presence: true
  validates :status, presence: true # TODO this is a controlled vocabulary

  def identifier
    id.to_s
  end

  def username
    user.username
  end

  def content_type
    artifact.content_type
  end

  def storage_format
    artifact.storage_format
  end

  def complete!
    update!(status: "completed")
  end

  def fail!(errors)
    update!(status: "failed", error: errors.join("\n"))
  end

  def upload_link
    Services.incoming_storage.upload_link(self)
  end

end
