# frozen_string_literal: true

module V2
  class ArtifactsController < ResourceController

    collection_policy ArtifactsPolicy

    def self.of_any_type
      AnyArtifact.new
    end

    def show
      @artifact = Artifact.find(params[:id])
      render json: @artifact, status: 200
    end

    def create
      collection_policy.new(current_user).authorize! :new?
      # We don't explicitly check for :save? permissions

      if (duplicate = Artifact.find_by(id: params[:id]))
        resource_policy.new(current_user, duplicate).authorize! :show?
        head 303, location: v2_artifact_path(duplicate)
      else
        @artifact = new_artifact(params)
        if @artifact.valid?
          @artifact.save!
          render json: @artifact, status: 201, location: v2_artifact_path(@artifact)
        else
          render json: @artifact.errors, status: :unprocessable_entity
        end
      end
    end

    private

    def new_artifact(params)
      Artifact.new(
        id: params[:id],
        user: current_user,
        storage_format: params[:storage_format],
        content_type: params[:content_type]
      )
    end

  end
end
