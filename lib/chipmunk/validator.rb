# frozen_string_literal: true

Dir[File.join(__dir__, "validator", "**", "*.rb")].each {|file| require_relative file }
