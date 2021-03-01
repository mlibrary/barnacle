# frozen_string_literal: true

class QueueItem < ApplicationRecord

  scope :owned, ->(user_id) { joins(:package).where(packages: { user_id: user_id }) if user_id }

  enum status: {
    pending: 0,
    failed:  1,
    done:    2
  }

  belongs_to :package

  validates :status, presence: true
  validates :package_id, presence: true

  def user
    package.user
  end

  def success!
    update!(status: :done)
  end

  def fail!(errors)
    update!(status: :failed, error: errors.join("\n\n"))
  end

  scope :for_package, ->(package_id) { where(package_id: package_id) unless package_id.blank? }
  scope :for_packages, ->(package_scope) { joins(:package).merge(package_scope) }
  scope :recent_first, -> { order(updated_at: :desc) }

  scope :before_time, ->(time) { where("queue_items.updated_at < ?", time) }
  scope :after_time, ->(time) { where("queue_items.updated_at > ?", time) }
end
