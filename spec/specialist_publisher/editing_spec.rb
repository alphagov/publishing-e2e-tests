feature "Editing with Specialist Publisher", specialist_publisher: true, government_frontend: true do
  include SpecialistPublisherHelpers

  let(:old_title) { "Editing Specialist Publisher Old title #{SecureRandom.uuid}" }
  let(:new_title) { "Editing Specialist Publisher New title #{SecureRandom.uuid}" }

  scenario "Editing an Asylum Support Decision" do
    given_there_is_an_asylum_support_decision
    when_i_edit_it
    then_i_can_see_the_edits_on_draft_gov_uk
  end

  def signin_to_signon
    @user = signin_with_next_user(
      "Specialist Publisher" => %w[editor gds_editor],
      "Content Preview" => [],
    )
  end

  def given_there_is_an_asylum_support_decision
    signin_to_signon if use_signon?
    visit_specialist_publisher("/asylum-support-decisions/new")

    fill_in_asylum_support_decision_form(title: old_title)

    click_button("Save as draft")
    expect_created_alert(old_title)
  end

  def when_i_edit_it
    visit(Plek.find("specialist-publisher") + "/asylum-support-decisions")
    click_link(old_title)
    click_link("Edit document")

    fill_in("Title", with: new_title)
    click_button("Save as draft")

    expect_updated_alert(new_title)
  end

  def then_i_can_see_the_edits_on_draft_gov_uk
    signin_to_draft_origin(@user) if use_signon?

    url = find_link("Preview draft")[:href]
    reload_url_until_status_code(url, 200)

    click_link("Preview draft")
    expect_rendering_application("government-frontend")
    expect_url_matches_draft_gov_uk
    expect(page).to have_content(new_title)
  end
end
