# frozen_string_literal: true

shared_examples "autocomplete address" do
  it "contains a empty datalist" do
    within "#address_input" do
      expect(page).to have_css("#here_suggestions", count: 1, visible: false)
      expect(page).to have_css("#here_suggestions option", count: 0)
    end
  end

  context "on user typing" do
    it "add options in datalist" do
      within "#address_input" do
        fill_in "proposal[address]", with: "avenue des champs"
        expect(page).to have_css("#here_suggestions", count: 1)
      end
    end
  end
end
