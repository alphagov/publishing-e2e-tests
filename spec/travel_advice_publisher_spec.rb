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
    let(:country) { "Mexico" }

    after do
      delete_existing_draft(country)
    end

    scenario "creating a new edition (Draft)" do
      create_new_edition_draft(title, summary, part_title, part_body, country)
      save_new_edition
      within_window(preview_edition(country)) do
        expect_new_edition(summary)
        view_new_part(part_title)
        expect_new_part(part_body)
      end
    end

    scenario "creating a new edition (Published)" do
      create_new_edition_draft(title, summary, part_title, part_body, country)
      save_draft_publish
      within_window(view_published_frontend(country)) do
        expect_published_edition(summary)
      end
    end
  end

  feature "attaching files on TAP" do
    let(:title) { title_timestamp }
    let(:summary) { Faker::Lorem.paragraph }
    let(:part_title) { Faker::Book.title }
    let(:part_body) { Faker::Lorem.sentence }
    let(:country) { "Barbados" }
    let(:image) { File.expand_path("./fixtures/Example_map.jpg", File.dirname(__FILE__)) }
    let(:file) { File.expand_path("./fixtures/Example_map.pdf", File.dirname(__FILE__)) }

    after do
      delete_existing_draft(country)
    end

    scenario "attaching an image and pdf file" do
      create_new_edition_draft(title, summary, part_title, part_body, country)
      attach_a_files
      save_new_edition
      within_window(preview_edition(country)) do
        expect_new_edition(summary)
        expect_attachment_on_frontend
        download_example_pdf
        expect_example_file_downloaded
      end
    end
  end
end
