# frozen_string_literal: true

module V1
  class AuditsController < ResourceController
    collection_policy AuditsPolicy
    resource_policy AuditPolicy

    def index
      policy = collection_policy.new(current_user)
      policy.authorize! :index?
      @audits = policy.resolve.map {|audit| AuditPresenter.new(audit, expand: expand?) }
    end

    def show
      @audit = AuditPresenter.new(Audit.find(params[:id]).tap {|a| resource_policy.new(current_user, a).authorize! :show? }, expand: expand?)
    end

    def create
      collection_policy.new(current_user).authorize! :new?
      audit = RepositoryAuditJob.perform_now(user: current_user)

      head 201, location: v1_audit_path(audit)
    end

    private

    def expand?
      ActiveModel::Type::Boolean.new.cast(params.key?(:expand))
    end
  end
end
