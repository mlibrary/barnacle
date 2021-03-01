# frozen_string_literal: true

class ArtifactsPolicy < CollectionPolicy
  def index?
    can?(:show, Artifact.of_any_type)
  end

  def new?
    can?(:save, Artifact.of_any_type)
  end

  def base_scope
    Artifact.all
  end

  def resolve
    # Via the role map resolver, a user has access to:
    #   * All artifacts, if the user is an administrator
    #   * Artifacts of content types for which the user is a content manager
    #   * Artifacts of content types for which the user is authorized viewer
    #   * Any specific artifacts for which the user is granted access
    ViewableResources.for(user, scope)
  end
end
