Given("I am a Bentley audio content steward") do
  make_me_a("content_manager").on_all("audio")
end

Given("I have no role") do
  me
end

Then("my request is denied") do
  expect(last_response.status).to eq 403
end

