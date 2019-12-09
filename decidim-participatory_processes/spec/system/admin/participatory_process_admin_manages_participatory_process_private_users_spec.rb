# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process private users", type: :system do
  include_context "when process admin administrating a participatory process"

  it_behaves_like "manage participatory process private users examples"
end
