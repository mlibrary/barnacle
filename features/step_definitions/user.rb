# frozen_string_literal: true

Given("I am a Bentley audio content steward") do
  make_me_a("content_manager").on_all("audio")
end

Given("I am a repository administrator") do
  make_me_an("admin").on_everything
end

Given("I am a subject librarian") do
  make_me_a("subject_librarian").on_all("sociology_and_applied_psychology")
end

Given("I have no role") do
  me
end

Then("my request is denied") do
  expect(last_response.status).to eq 403
end
