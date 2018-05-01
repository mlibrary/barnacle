# frozen_string_literal: true

require "rails_helper"

RSpec.describe V1::AuditController, type: :controller do
  describe "/v1" do
    describe "POST #create" do
      # create two packages
      context "as an administrator" do
        include_context "as admin user"
        it "starts a FixityCheckJob for each package" do
          request.headers.merge! auth_header
          allow(FixityCheckJob).to receive(:perform_later)
          packages = Array.new(2) { Fabricate(:package) }

          post :create

          packages.each do |package|
            expect(FixityCheckJob).to have_received(:perform_later).with(package, user)
          end
        end
      end

      context "as a non-admin" do
        include_context "as underprivileged user"

        before(:each) do
          allow(FixityCheckJob).to receive(:perform_later)
          request.headers.merge! auth_header
          post :create
        end

        it "returns a 403" do
          expect(response).to have_http_status(403)
        end

        it "does not start any jobs" do
          expect(FixityCheckJob).not_to have_received(:perform_later)
        end
          
      end

      context "as a user that is not logged in" do
        before(:each) do
          allow(FixityCheckJob).to receive(:perform_later)
          post :create
        end

        it "returns a 401" do
          expect(response).to have_http_status(401)
        end

        it "does not start any jobs" do
          expect(FixityCheckJob).not_to have_received(:perform_later)
        end
      end
    end
  end
end
