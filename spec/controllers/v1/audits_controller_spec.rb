# frozen_string_literal: true

require "rails_helper"

RSpec.describe V1::AuditsController, type: :controller do
  describe "/v1" do

    describe "GET #show" do
      let!(:audit) { Fabricate(:audit) }
      include_context "as admin user"

      it "assigns an audit presenter" do
        get :show, params: { id: audit.id }
        expect(assigns(:audit).successes.count).to eq(0)
      end

      it "does not expand the audit by default" do
        get :show, params: { id: audit.id }
        expect(assigns(:audit).expand?).to be false
      end

      it "can expand the audit" do
        get :show, params: { id: audit.id, expand: true }
        expect(assigns(:audit).expand?).to be true
      end
      
      it "checks the policy" do
        expect_resource_policy_check(policy: AuditPolicy, user: user, resource: audit, action: :show?)

        get :show, params: { id: audit.id }
      end
    end

    describe "GET #index" do
      let!(:audit) { Fabricate(:audit) }
      include_context "as admin user"

      it "assigns an array of audit presenters" do
        get :index
        expect(assigns(:audits).first.successes.count).to eq(0)
      end

      it "does not expand the audits" do
        get :index
        expect(assigns(:audits).first.expand?).to be false
      end

      it "checks the policy" do
        expect_collection_policy_check(policy: AuditsPolicy, user: user, action: :index?)

        get :index
      end
    end

    describe "POST #create" do
      # create two packages
      include_context "as admin user"

      let!(:packages) { Array.new(2) { Fabricate(:package) } }
      let!(:unstored_package) { Fabricate(:package, storage_location: nil) }

      before(:each) do
        # should not appear in audit since it has no storage to audit
        allow(AuditFixityCheckJob).to receive(:perform_later)
      end

      it "starts a AuditFixityCheckJob for each stored package" do
        post :create

        packages.each do |package|
          expect(AuditFixityCheckJob).to have_received(:perform_later).with(package: package, user: user, audit: anything)
        end
      end

      it "creates an Audit object" do
        post :create

        expect(Audit.count).to eql(1)
      end

      it "creates an Audit object whose owners is the current user" do
        post :create

        expect(Audit.first.user).to eq(user)
      end

      it "creates an Audit object whose count is the number of packages" do
        post :create

        expect(Audit.first.packages).to eql(2)
      end

      it "does not start a AuditFixityCheckJob for unstored packages (requests)" do
        post :create

        expect(AuditFixityCheckJob).not_to have_received(:perform_later).with(package: unstored_package, user: user, audit: anything)
      end

      it "returns 201" do
        post :create
        expect(response).to have_http_status(201)
      end

      it "correctly sets the location header" do
        post :create
        expect(response.location).to eql(v1_audit_path(Audit.first))
      end

      it "renders nothing" do
        post :create
        expect(response).to render_template(nil)
      end

      it "checks the policy" do
        expect_collection_policy_check(policy: AuditsPolicy, user: user, action: :create?)

        post :create
      end
    end
  end
end
