# frozen_string_literal: true

require "request_builder"

module V1
  class BagsController < ApplicationController

    # GET /bags
    def index
      @bags = policy_scope(Bag)
    end

    # GET /bags/1
    # GET /bags/39015012345678
    def show
      @bag = bag
    end

    # POST /v1/requests
    def create
      authorize Bag
      status, @request_record = RequestBuilder.new
        .create(create_params.merge(user: current_user))
      case status
      when :duplicate
        head 303, location: v1_request_path(@request_record)
      when :created
        head 201, location: v1_request_path(@request_record)
      when :invalid
        render json: @request_record.errors, status: :unprocessable_entity
      end
    end

    def fixity_check
      FixityCheckJob.perform_later(bag, current_user)
    end

    private

    def bag
      (Bag.find_by_bag_id(params[:bag_id]) ||
       Bag.find_by_external_id!(params[:bag_id])).tap do |bag|
        authorize bag, :show?
      end
    end

    private

    def create_params
      params.permit([:bag_id, :external_id, :content_type])
        .to_h
        .symbolize_keys
    end

    def bag
      (Bag.find_by_bag_id(params[:bag_id]) ||
       Bag.find_by_external_id!(params[:bag_id])).tap do |bag|
        authorize bag
      end
    end

  end
end
