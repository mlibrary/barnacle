# frozen_string_literal: true

class Revision < ApplicationRecord
  belongs_to :artifact
  belongs_to :deposit
end
