feature "Change notes on Specialist Publisher", specialist_publisher: true, government_frontend: true do
  include SpecialistPublisherHelpers

  let(:title) { "Change note Specialist Publisher #{SecureRandom.uuid}" }
  let(:old_body) { Faker::Lorem.paragraph }
  let(:new_body) { Faker::Lorem.paragraph }
  let(:change_note) { Faker::Lorem.sentence }

  scenario "Change note on a Countryside Stewardship Grant" do
    given_there_is_a_published_countryside_stewardship_grant
    when_i_edit_it_with_a_change_note
    and_publish_it
    then_i_can_view_the_change_note_on_gov_uk
  end

  def signin_to_signon
    @user = signin_with_next_user(
      "Specialist Publisher" => %w[editor gds_editor],
    )
  end

  def given_there_is_a_published_countryside_stewardship_grant
    signin_to_signon if use_signon?
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
    url = find_link("View on website")[:href]

    reload_url_until_status_code(url, 200)
    reload_url_until_match(url, :has_text?, ignore_quotes_regex(new_body))

    click_link("View on website")
    expect_rendering_application("government-frontend")
    expect_url_matches_live_gov_uk
    click_link("show all updates")
    within("#full-history") do
      expect(page).to have_content(ignore_quotes_regex(change_note))
    end
  end
end
