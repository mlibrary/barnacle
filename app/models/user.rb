# frozen_string_literal: true

class User < ApplicationRecord

  attr_writer :identity

  validates :email, presence: true
  validates :admin, inclusion: { in: [true, false] }
  validates :api_key_digest, presence: true
  validates :username, presence: true

  # Assign an API key
  after_initialize :add_key, on: :create

  def self.system_user
    new(username: "(system)", email: Chipmunk.config["admin_email"])
  end

  def api_key
    @api_key ||= if [nil, "x"].include?(api_key_digest)
      Keycard::DigestKey.new
    else
      Keycard::DigestKey.new(api_key_digest)
    end
  end

  def known?
    persisted?
  end

  def agent_type
    "user"
  end

  def agent_id
    username
  end

  def identity
    @identity ||= { username: username }.reject {|_, v| v.nil? }
  end

  def self.guest(username = nil)
    new(username: username || "<guest>", email: "").tap(&:readonly!)
  end

  def self.authenticate_by_id(id)
    User.find_by(id: id)
  end

  def self.authenticate_by_auth_token(token)
    digest = Keycard::DigestKey.new(key: token).digest
    User.find_by(api_key_digest: digest)
  end

  # If we get an EID, we will create a guest for anyone who is not registered.
  def self.authenticate_by_user_eid(user_eid)
    User.find_by(username: user_eid) || User.guest(user_eid)
  end

  private

  def add_key
    self.api_key_digest = api_key.digest
  end
end
