# frozen_string_literal: true

class RepositoryAuditJob < ApplicationJob
  def perform(user: User.system_user)
    packages = Package.stored
    audit = Audit.create(user: user, packages: packages.count)
    packages.each do |package|
      AuditFixityCheckJob.perform_later(package: package, user: user, audit: audit)
    end
    audit
  end
end
