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

gem "bagit"
gem "bcrypt", "~> 3.1.7"
gem "ettin"
gem "canister"
gem "jbuilder"
gem "mysql2", "~>0.4.10"
gem "pundit"
gem "rack-cors"
gem "rails", "~> 5.1.0"
gem "resque"
gem "resque-pool"

gem 'checkpoint', github: 'mlibrary/checkpoint'

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
  gem "rspec"
  gem "rspec-activejob"
  gem "rspec-rails"
  gem "simplecov"
  gem "timecop"
  gem "turnip"
  gem "webmock"
end

group :development do
  gem "rubocop"
end
