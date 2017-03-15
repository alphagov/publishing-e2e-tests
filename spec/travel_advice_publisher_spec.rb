require "spec_helper"
require "plek"
require "faker"
require "date"

describe "travel advice publisher", type: :feature do
  feature "Creating and deleting new editions" do
    let(:title) { title_timestamp }
    let(:summary) { Faker::Lorem.paragraph }
    let(:part_title) { Faker::Book.title }
    let(:part_body) { Faker::Lorem.sentence }

    scenario "creating a new edition (Draft)" do
      create_new_edition_draft(title, summary, part_title, part_body)
      save_new_edition
      preview_edition
      expect_new_edition(summary)
      view_new_part(part_title)
      expect_new_part(part_body)
    end

    scenario "creating a new edition (Published)" do
      create_new_edition_draft
      save_draft_publish
      view_published_frontend
      expect_published_edition(summary)
    end
  end
end
