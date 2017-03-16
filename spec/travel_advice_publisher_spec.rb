require "spec_helper"
require "plek"
require "faker"
require "date"

describe "travel advice publisher", type: :feature, travel_advice_publisher: true do
  feature "Creating and deleting new editions" do
    let(:title) { title_timestamp }
    let(:summary) { Faker::Lorem.paragraph }
    let(:part_title) { Faker::Book.title }
    let(:part_body) { Faker::Lorem.sentence }

    after do
      delete_existing_draft
    end

    scenario "creating a new edition (Draft)" do
      create_new_edition_draft(title, summary, part_title, part_body)
      save_new_edition
      preview_edition
      expect_new_edition(summary)
      view_new_part(part_title)
      expect_new_part(part_body)
    end

    scenario "creating a new edition (Published)" do
      create_new_edition_draft(title, summary, part_title, part_body)
      save_draft_publish
      view_published_frontend
      expect_published_edition(summary)
    end
  end

  feature "attaching files on TAP" do
    let(:title) { title_timestamp }
    let(:summary) { Faker::Lorem.paragraph }
    let(:part_title) { Faker::Book.title }
    let(:part_body) { Faker::Lorem.sentence }
    let(:image) { File.expand_path("./fixtures/world_map.png", File.dirname(__FILE__)) }
    let(:file) { File.expand_path("./fixtures/Charities_and_corporation_tax_returns.pdf", File.dirname(__FILE__)) }

    after do
      delete_existing_draft
    end

    scenario "attaching an image and pdf file" do
      create_new_edition_draft(title, summary, part_title, part_body)
      attach_a_files
      save_new_edition
      preview_edition
      expect_published_edition(summary)
      expect_file_attached
    end
  end
end
