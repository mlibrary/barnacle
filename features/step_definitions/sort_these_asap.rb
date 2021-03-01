# frozen_string_literal: true

Given("I am a content steward") do
  make_me_a("content_manager").on_all("audio")
end

Given("an audio object that is not in the repository") do
  @bag = Chipmunk::Bag.new(fixture("14d25bcd-deaf-4c94-add7-c189fdca4692"))
end

When("I deposit the object as a bag") do
  api_post(
    "/v2/artifacts",
    id: @bag.external_id,
    content_type: @bag.content_type,
    storage_format: "bag"
  )

  api_post("/v2/artifacts/#{@bag.external_id}/revisions")
  deposit = JSON.parse(last_response.body)
  FileUtils.cp_r @bag.bag_dir, deposit["upload_link"].split(":").last
  api_post("/v2/deposits/#{deposit["id"]}/complete") # Should this be a put?
end

Then("it is preserved as an artifact") do
  @artifact = Artifact.find(@bag.external_id)
  expect(Services.storage.for(@artifact)).to be_valid
end

Then("the artifact has the identifier from within the bag") do
  api_get(
    "/v2/artifacts/#{@bag.external_id}/"
  )
  expect(last_response.successful?).to be true
end

Given("a preserved audio artifact") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I attempt to deposit the object as a bag to create a new artifact") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("it is rejected as already preserved") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("I am a subject librarian") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I download the complete artifact") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I receive the latest revision as a bag") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I am seeking a known revision of the artifact") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I receive the specified revision as a bag") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("a preserved audio artifact with multiple revisions") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I receive the latest revision of the file as a download") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("a perserved audio artifact with multiple revisions") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I attempt to download a file from the artifact") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I receive the specified revision of the file as a download") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I revise the artifact by uploading a new edition") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the artifact has one new revision") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the contents are updated to match my new edition") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("a completed deposit") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I check on the deposit") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I receive a report that the deposit is completed") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("an in progress deposit") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I receive a report that the deposit is ingesting") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("a failed deposit") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I receive a report that the deposit failed") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("a new deposit") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I receive a report that the deposit is started") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I signal that the artifact is fully uploaded") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the deposit is ingesting") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("the deposit's ingest completes") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("an artifact with one revision in the repository") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("I have a new revision of my Bentley audio bag to deposit") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("a new deposit for my artifact") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("an in progress deposit for my artifact") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the new revision is attached to the artifact") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("a deposit") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I view the artifact") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I see the latest revision") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I see the artifact metadata") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I see the list of files in the artifact") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I see the specified revision") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I view the revision history of the artifact") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I see all of the revisions listed with timestamps") do
  pending # Write code here that turns the phrase above into concrete actions
end
