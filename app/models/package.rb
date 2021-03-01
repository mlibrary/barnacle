# frozen_string_literal: true

class Package < ApplicationRecord

  belongs_to :user
  has_one :queue_item
  has_many :events

  scope :stored, -> { Package.where.not(storage_volume: nil, storage_path: nil) }
  scope :owned, ->(user_id) { Package.where(user_id: user_id) }
  scope :with_type, ->(content_type) { Package.where(content_type: content_type) }
  scope :with_type_and_id, ->(content_type, id) { Package.where(content_type: content_type, id: id) }

  def to_param
    bag_id
  end
  alias_method :identifier, :to_param

  validates :bag_id, presence: true, length: { minimum: 6 }
  validates :user_id, presence: true
  validates :external_id, presence: true
  validates :format, presence: true, format: /bag/

  # Declare the policy class to use for authz
  def self.policy_class
    PackagePolicy
  end

  # Rails overrides the format param on requests, so we rename this to storage_format.
  # This alias is for backwards compatibility
  # alias_method :storage_format, :format
  def storage_format
    format
  end

  def username
    user.username
  end

  def upload_link
    Services.incoming_storage.upload_link(self)
  end

  def stored?
    !storage_volume.nil? && !storage_path.nil?
  end

  # V1 API exposes the absolute path to storage.
  def storage_location
    package_storage.for(self).path if stored?
  rescue Chipmunk::PackageNotFoundError
    storage_path
  end

  def resource_type
    content_type
  end

  def self.resource_types
    content_types
  end

  def self.content_types
    Rails.application.config.validation["bagger_profile"].keys +
      Rails.application.config.validation["external"].keys
  end

  def self.of_any_type
    AnyPackage.new
  end

  class AnyPackage
    def to_resources
      Package.content_types.map {|t| Checkpoint::Resource::AllOfType.new(t) }
    end

    def resource_type
      "Package"
    end

    def resource_id
      Checkpoint::Resource::ALL
    end
  end

  private

  def package_storage
    @package_storage ||= Services.storage
  end

  def incoming_storage
    @incoming_storage ||= Services.incoming_storage
  end
end
