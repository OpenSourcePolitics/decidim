# frozen_string_literal: true

shared_examples "autocomplete address" do |params = {}|
  let(:result) do
    {
      suggestions: [
        {
          matchLevel: "street",
          address: {
            street: "place de la Bourse",
            postalCode: "75002",
            city: "Paris"
          },
          label: "France, Paris, 75002, Paris, Place de la Bourse"
        }
      ]
    }
  end

  let(:option_value) { "#{result[:suggestions].first[:address][:street]} #{result[:suggestions].first[:address][:postalCode]} #{result[:suggestions].first[:address][:city]}" }

  before do
    visit params[:path] unless params[:path].nil?
    page.execute_script("$(\"#here_suggestions\").append(new Option(\"#{result[:suggestions].first[:label]}\",\"#{option_value}\"))")
  end

  it "contains a empty datalist" do
    within "#address_input" do
      expect(page).to have_css("#here_suggestions", count: 1, visible: false)
      expect(page).to have_css("#here_suggestions option", count: 0)
    end
  end

  context "when user type" do
    before do
      fill_in "proposal[address]", with: "place de"
    end

    it "fills the datalist" do
      within "#address_input" do
        expect(page).to have_css("#here_suggestions", count: 1, visible: false)
        expect(page).to have_css("#here_suggestions option", count: 1, visible: false)
        page.select option_value, from: "proposal_address", wait: 2

        expect(find("#proposal_address").value).to eq(option_value)
      end
    end
  end
end
