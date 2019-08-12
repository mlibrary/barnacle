# frozen_string_literal: true

module V2
  class ArtifactsController < ResourceController

    collection_policy ArtifactsPolicy

    def self.of_any_type
      AnyArtifact.new
    end

    def create
      collection_policy.new(current_user).authorize! :new?
      # We don't explicitly check for :save? permissions

      if duplicate = Artifact.find_by_artifact_id(params[:artifact_id])
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
      # TODO: Should artifact have a format?
      Artifact.new(
        artifact_id: params[:artifact_id],
        user: current_user,
        content_type: params[:content_type]
      )
    end

  end
end