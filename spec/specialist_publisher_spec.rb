require "spec_helper"
require "plek"
require "faker"

describe "specialist publisher", type: :feature do

  feature "Publishes an AAIB Report" do
    let(:title) { Faker::Book.title }
    let(:summary) { Faker::Lorem.sentence }

    scenario "sucessfully" do
      visit("#{Plek.new.find('specialist-publisher')}/aaib-reports/new")
      fill_in("Title", with: title)
      fill_in("Summary", with: summary)
      fill_in("Body", with: Faker::Lorem.paragraph)
      fill_in("[aaib_report]date_of_occurrence(1i)", with: "2016")
      fill_in("[aaib_report]date_of_occurrence(2i)", with: "11")
      fill_in("[aaib_report]date_of_occurrence(3i)", with: "10")
      click_button("Save as draft")
      click_button("Publish")
      click_link("View on website")
      expect(page).to have_content(title)
      expect(page).to have_selector(
        "meta[name='govuk:rendering-application'][content='specialist-frontend']",
        visible: false
      )
      expect(page).to have_current_path(%r{^/aaib-reports})
    end
  end
end
