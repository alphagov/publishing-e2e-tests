require "spec_helper"
require "gds_api/publishing_api_v2"
require "plek"
require "faker"

describe "specialist publisher", type: :feature do
  def publishing_api
    @publishing_api ||= GdsApi::PublishingApiV2.new(
      Plek.new.find("publishing-api"),
      bearer_token: "token",
    )
  end

  def create_organisations
    content = {
      "38eb5d8f-2d89-480c-8655-e2e7ac23f8f4" => "Air Accidents Investigation Branch",
      "caeb418c-d11c-4352-92e9-47b21289f696" => "Employment Appeal Tribunal",
      "dcc907d6-433c-42df-9ffb-d9c68be5dc4d" => "Ministry of Justice",
      "1a68b2cc-eb52-4528-8989-429f710da00f" => "Upper Tribunal (Tax and Chancery Chamber)",
      "2e7868a8-38f5-4ff6-b62f-9a15d1c22d28" => "Department for Communities and Local Government",
      "db994552-7644-404d-a770-a2fe659c661f" => "Department for International Development",
      "240f72bd-9a4d-4f39-94d9-77235cadde8e" => "Medicines and Healthcare products Regulatory Agency",
      "e8fae147-6232-4163-a3f1-1c15b755a8a4" => "Rural Payments Agency",
      "b548a09f-8b35-4104-89f4-f1a40bf3136d" => "Department for Work and Pensions",
      "d39237a5-678b-4bb5-a372-eb2cb036933d" => "Driver and Vehicle Standards Agency",
      "de4e9dc6-cca4-43af-a594-682023b84d6c" => "Department for Environment, Food & Rural Affairs",
      "013872d8-8bbb-4e80-9b79-45c7c5cf9177" => "Rail Accident Investigation Branch",
      "d3ce4ba7-bc75-46b4-89d9-38cb3240376d" => "Natural England",
      "6f757605-ab8f-4b62-84e4-99f79cf085c2" => "Gwasanaeth Llysoedd a Thribiwnlysoedd Ei Mawrhydi",
      "9c66b9a3-1e6a-48e8-974d-2a5635f84679" => "Marine Accident Investigation Branch",
      "7141e343-e7bb-483b-920a-c6a5cf8f758c" => "First-tier Tribunal (Asylum Support)",
      "957eb4ec-089b-4f71-ba2a-dc69ac8919ea" => "Competition and Markets Authority",
      "4c2e325a-2d95-442b-856a-e7fb9f9e3cf8" => "Upper Tribunal (Administrative Appeals Chamber)"
    }
    content.each do |content_id, title|
      slug = title.downcase.strip.tr(" ", "-").gsub(/[^\w-]/, "")
      base_path = "/government/organisations/#{slug}"
      payload = {
        base_path: base_path,
        details: {},
        document_type: "placeholder_organisation",
        locale: "en",
        public_updated_at: DateTime.now.rfc3339,
        publishing_app: "whitehall",
        rendering_app: "whitehall-frontend",
        routes: [{ path: base_path, type: "exact" }],
        schema_name: "placeholder_organisation",
        title: title,
        update_type: "major",
      }
      publishing_api.put_content(content_id, payload)
      publishing_api.publish(content_id, nil)
    end
  end

  def create_finders
    content = {
      "b7574bba-969f-4c49-855a-ae1586258ff6" => {
        title: "Air Accidents Investigation Branch reports",
        base_path: "/aaib-reports",
        details: {
          document_noun: "report",
          filter: { document_type: "aaib_report" },
          format_name: "Air Accidents Investigation Branch report",
          show_summaries: true,
          facets: [],
        },
        organistaions: ["38eb5d8f-2d89-480c-8655-e2e7ac23f8f4"],
      },
    }

    content.each do |content_id, content|
      payload = {
        base_path: content[:base_path],
        details: content[:details],
        document_type: "finder",
        locale: "en",
        public_updated_at: DateTime.now.rfc3339,
        publishing_app: "specialist-publisher",
        rendering_app: "finder-frontend",
        routes: [
          { path: content[:base_path], type: "exact" },
          { path: "#{content[:base_path]}.json", type: "exact" },
          { path: "#{content[:base_path]}.atom", type: "exact" },
        ],
        schema_name: "finder",
        title: content[:title],
        update_type: "major",
      }
      publishing_api.put_content(content_id, payload)
      publishing_api.patch_links(content_id, links: { organisations: content[:organistaions] })
      publishing_api.publish(content_id, nil)
    end

  end

  before :all do
    create_organisations
    create_finders
  end

  feature "Publishes an AAIB Report" do
    let(:title) { Faker::Book.title }
    let(:summary) { Faker::Lorem.sentence }
    let(:slug) { title.downcase.tr(" ", "-") }

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
      expect(page).to have_current_path(%r{^/aaib-reports/#{slug}})
    end
  end
end
