# frozen_string_literal: true

class QueueItemsPolicy < CollectionPolicy

  def initialize(user, scope = nil, packages_policy: PackagesPolicy.new(user))
    super(user, scope)
    @packages_policy = packages_policy
  end

  def index?
    packages_policy.index?
  end

  def new?
    packages_policy.new?
  end

  def base_scope
    QueueItem.all
  end

  def resolve
    scope.for_packages(packages_policy.resolve)
  end

  private

  attr_reader :packages_policy
end
