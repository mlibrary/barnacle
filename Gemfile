# frozen_string_literal: true

# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "nio4r", "= 2.5.2"
gem "puma", "4.3.8"

gem "bagit"
gem "bcrypt", "~> 3.1.7"
gem "canister"
gem "ettin"
gem "jb"
gem "jbuilder"
gem "mysql2", "~>0.4.10"
gem "rack-cors"
gem "rails", "~> 5.1.0"
gem "resque"
gem "resque-pool"
gem "semantic_logger"
gem "zip_tricks"

gem "checkpoint", "~> 1.1.3"
gem "kcv", "~> 0.4.0"
gem "keycard", "~> 0.3.3"

group :development, :test do
  gem "byebug", platforms: [:mri]
  gem "fabrication"
  gem "faker"
  gem "pry"
  gem "pry-byebug"
  gem "rails-controller-testing"
  gem "sqlite3"
end

group :test do
  gem "coveralls"
  gem "cucumber-rails", require: false
  gem "database_cleaner"
  gem "rspec"
  gem "rspec-activejob"
  gem "rspec-rails"
  gem "webmock"
end

group :development do
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rspec"
  gem "yard"
end
