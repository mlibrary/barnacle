# frozen_string_literal: true

require "rails_helper"

RSpec.describe V1::PackagesController, type: :controller do
  include Checkpoint::Spec::Controller

  describe "/v1" do
    it "uses PackagesPolicy as its collection_policy" do
      policy = controller.send(:collection_policy)
      expect(policy).to eq PackagesPolicy
    end

    it "uses PackagePolicy as its resource_policy" do
      policy = controller.send(:resource_policy)
      expect(policy).to eq PackagePolicy
    end

    it_behaves_like "an index endpoint", "PackagesPolicy"

    describe "GET #show" do
      let(:package) { Fabricate(:package) }
      let(:bag) { double(:bag) }

      before(:each) { allow(Services.storage).to receive(:for).with(package).and_return(bag) }

      context "when the policy allows the user access" do
        include_context "with someone logged in"

        before(:each) { resource_policy "PackagePolicy", show?: true }

        it "returns 200" do
          get :show, params: { bag_id: package.bag_id }
          expect(response).to have_http_status(200)
        end

        it "renders the package" do
          get :show, params: { bag_id: package.bag_id }
          expect(assigns(:package)).to eq package
        end

        it "renders the bag" do
          get :show, params: { bag_id: package.bag_id }
          expect(assigns(:bag)).to eq bag
        end

        it "renders the show template" do
          get :show, params: { bag_id: package.bag_id }
          expect(response).to render_template(:show)
        end
      end

      context "when the record does not exist" do
        include_context "with someone logged in"

        it "raises an ActiveRecord::RecordNotFound" do
          expect do
            get :show, params: { bag_id: "(missing)" }
          end.to raise_exception ActiveRecord::RecordNotFound
        end
      end

      context "when the policy denies the user access" do
        include_context "with someone logged in"

        before(:each) { resource_policy "PackagePolicy", show?: false }

        it "responds with 403 Forbidden" do
          get :show, params: { bag_id: package.bag_id }
          expect(response).to have_http_status(:forbidden)
        end
      end

      context "with the external_id supplied" do
        include_context "with someone logged in"
        let(:package) { Fabricate(:package, user: user) }

        before(:each) { resource_policy "PackagePolicy", show?: true }

        it "fetches the package" do
          get :show, params: { bag_id: package.external_id }

          expect(assigns(:package)).to eql(package)
        end

        it "renders the bag" do
          get :show, params: { bag_id: package.bag_id }
          expect(assigns(:bag)).to eq bag
        end
      end
    end

    describe "GET #sendfile" do
      include_context "with someone logged in"

      let(:package) { Fabricate(:stored_package, user: user) }

      before(:each) { resource_policy "PackagePolicy", show?: true }

      context "the file is not present in the bag" do
        it "returns a 404 if the file isn't present in the bag" do
          get :sendfile, params: { bag_id: package.bag_id, file: "nonexistent" }

          expect(response).to have_http_status(:not_found)
        end
      end

      context "the file exists in the bag" do
        it "returns 204 No Content on success" do
          get :sendfile, params: { bag_id: package.bag_id, file: "samplefile" }

          expect(response).to have_http_status(:no_content)
        end
      end
    end

    describe "GET #send_package" do
      include_context "with someone logged in"

      before(:each) { resource_policy "PackagePolicy", show?: true }

      context "the package is not stored" do
        let(:package) { Fabricate(:package, user: user, storage_location: nil) }

        it "returns a 404" do
          get :send_package, params: { bag_id: package.bag_id }

          expect(response).to have_http_status(:not_found)
        end
      end

      context "the package is stored" do
        let(:package) { Fabricate(:stored_package, user: user) }
        let(:zip) { double(:zip) }

        before(:each) do
          allow(controller).to receive(:zip_tricks_stream).and_yield(zip)
          allow(zip).to receive(:write_deflated_file).and_yield(double(:sink))
          allow(IO).to receive(:copy_stream)
        end

        it "zips each file in the stored package" do
          Services.storage.for(package).relative_files.each do |file|
            expect(zip).to receive(:write_deflated_file).with(file.to_s)
          end
          get :send_package, params: { bag_id: package.bag_id }
        end
        it "returns 204 No Content on success" do
          get :send_package, params: { bag_id: package.bag_id }

          expect(response).to have_http_status(204)
        end
      end
    end

    describe "POST #create" do
      let(:attributes) do
        {
          bag_id:       SecureRandom.uuid,
          content_type: "audio",
          external_id:  SecureRandom.uuid
        }
      end

      shared_context "mocked RequestBuilder" do |status|
        let(:result_request) do
          Fabricate(:package,
            bag_id: attributes[:bag_id],
            user: user,
            external_id: attributes[:external_id],
            content_type: attributes[:content_type])
        end
        let(:result_status) { status }
        let(:builder) { double(:builder) }
        before(:each) do
          allow(RequestBuilder).to receive(:new).and_return(builder)
          allow(builder).to receive(:create).and_return([result_status, result_request])
        end
      end

      context "as an authorized user" do
        include_context "with someone logged in"
        before(:each) { collection_policy "PackagesPolicy", create?: true }

        context "new record" do
          context "RequestBuilder returns a valid record" do
            include_context "mocked RequestBuilder", :created

            it "passes the parameters to a RequestBuilder" do
              post :create, params: attributes
              expect(RequestBuilder).to have_received(:new)
              expect(builder).to have_received(:create).with(attributes.merge(user: user))
            end
            it "returns 201 Created" do
              post :create, params: attributes
              expect(response).to have_http_status(:created)
            end
            it "correctly sets the location header" do
              post :create, params: attributes
              expect(response.location).to eql(v1_request_path(result_request))
            end
            it "renders nothing" do
              post :create, params: attributes
              expect(response).to render_template(nil)
            end
          end

          context "RequestBuilder returns an invalid record" do
            include_context "mocked RequestBuilder", :invalid
            it "returns 422" do
              post :create, params: attributes
              expect(response).to have_http_status(422)
            end
            it "renders nothing" do
              post :create, params: attributes
              expect(response).to render_template(nil)
            end
          end
        end

        context "as duplicate record" do
          include_context "mocked RequestBuilder", :duplicate

          it "does not create an additional record" do
            post :create, params: attributes
            expect(Package.count).to eql(1)
          end
          it "returns 303" do
            post :create, params: attributes
            expect(response).to have_http_status(303)
          end
          it "correctly sets the location header" do
            post :create, params: attributes
            expect(response.location).to eql(v1_request_path(result_request))
          end
          it "renders nothing" do
            post :create, params: attributes
            expect(response).to render_template(nil)
          end
        end
      end

      context "when the policy denies the user access" do
        include_context "with someone logged in"
        before(:each) { collection_policy create?: false }

        it "responds with 403 Forbidden" do
          post :create, params: attributes
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
