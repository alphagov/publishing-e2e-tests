require "spec_helper"
require "gds_api/publishing_api_v2"
require "plek"

describe "specialist publisher", type: :feature do
  before :all do
    content_id = "a148eb2c-e5aa-45bc-abfc-2a19d447ccf8"
    payload = {
      base_path: "/aaib-reports",
      details: {
        document_noun: "report",
        filter: { document_type: "aaib_report" },
        format_name: "Air Accidents Investigation Branch report",
        show_summaries: true,
        facets: [],
      },
      document_type: "finder",
      locale: "en",
      public_updated_at: DateTime.now.rfc3339,
      publishing_app: "specialist-publisher",
      rendering_app: "finder-frontend",
      routes: [
        { path: "/aaib-reports", type: "exact" },
        { path: "/aaib-reports.json", type: "exact" },
        { path: "/aaib-reports.atom", type: "exact" },
      ],
      schema_name: "finder",
      title: "Air Accidents Investigation Branch reports",
      update_type: "major",
    }
    publishing_api = GdsApi::PublishingApiV2.new(
      Plek.new.find("publishing-api"),
      bearer_token: "token",
    )
    begin
      publishing_api.get_content(content_id)
    rescue GdsApi::HTTPNotFound
      publishing_api.put_content(content_id, payload)
      publishing_api.publish(content_id, nil)
    end
  end

  let(:summary) { "A summary of my report" }

  it "can publish a AAIB report" do
    visit("http://specialist-publisher.dev.gov.uk/aaib-reports/new")
    fill_in("Title", with: "Test Report")
    fill_in("Summary", with: summary)
    fill_in("Body", with: "Lorem ipsum dolor sit amet.")
    fill_in("[aaib_report]date_of_occurrence(1i)", with: "2016")
    fill_in("[aaib_report]date_of_occurrence(2i)", with: "11")
    fill_in("[aaib_report]date_of_occurrence(3i)", with: "10")
    click_button("Save as draft")
    click_button("Publish")
    click_link("View on website")
    expect(page.body).to have_content(summary)
  end
end
