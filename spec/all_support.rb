# frozen_string_literal: true

support_dir = File.expand_path(File.join(__dir__, "support"))
[".", "examples", "contexts", "helpers"].each do |folder|
  Dir[File.join(support_dir, folder, "**", "*.rb")].each {|f| require f }
end
