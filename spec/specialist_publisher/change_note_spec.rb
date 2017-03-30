require "spec_helper"

feature "Change notes on Specialist Publisher", specialist_publisher: true do
  include SpecialistPublisherHelpers

  let(:title) { title_with_timestamp }
  let(:old_body) { Faker::Lorem.paragraph }
  let(:new_body) { Faker::Lorem.paragraph }
  let(:change_note) { Faker::Lorem.sentence }

  scenario "Change note on a Countryside Stewardship Grant" do
    given_there_is_a_published_countryside_stewardship_grant
    when_i_edit_it_with_a_change_note
    and_publish_it
    then_i_can_view_the_change_note_on_gov_uk
  end

  def given_there_is_a_published_countryside_stewardship_grant
    visit_specialist_publisher("/countryside-stewardship-grants/new")

    fill_in_countryside_stewardship_grant_form(title: title, body: old_body)
    click_button("Save as draft")
    expect_created_alert(title)

    page.accept_confirm do
      click_button("Publish")
    end
    expect_published_alert(title)
  end

  def when_i_edit_it_with_a_change_note
    click_link("Edit document")

    fill_in("Body", with: new_body)
    choose("Update type major")
    fill_in("Change note", with: change_note)

    click_button("Save as draft")

    expect_updated_alert(title)
  end

  def and_publish_it
    page.accept_confirm do
      click_button("Publish")
    end

    expect_published_alert(title)
  end

  def then_i_can_view_the_change_note_on_gov_uk
    click_link("View on website")
    reload_page_until(:has_text?, new_body)

    click_link("+ full page history")
    within("#full-history") do
      expect(page).to have_content(change_note)
    end
  end
end
