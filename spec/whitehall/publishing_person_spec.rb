feature "Publishing a person on Whitehall", new: true, whitehall: true do
  include WhitehallHelpers

  let(:forename) { "Adrian #{SecureRandom.uuid}" }

  scenario "Publishing a person on Whitehall" do
    given_i_have_a_person
    then_i_can_view_them_on_gov_uk
  end

  def given_i_have_a_person
    visit(Plek.find("whitehall-admin") + "/government/admin/people/new")
    fill_in "Forename", with: forename
    click_button "Save"
  end

  def then_i_can_view_them_on_gov_uk
    url = find_link("View on website")[:href]
    reload_url_until_status_code(url, 200)

    click_link "View on website"
    expect_rendering_application("whitehall")
    expect_url_matches_live_gov_uk
    expect(page).to have_content(forename)
  end
end
