feature "Publishing a contact", contacts: true, new: true, government_frontend: true do
  let(:title) { "Creating a contact #{SecureRandom.uuid}" }

  scenario "Creating a contact" do
    when_i_create_a_contact
    then_i_can_view_it_on_gov_uk
  end

  def when_i_create_a_contact
    visit(Plek.find("contacts-admin") + "/admin/contacts/new")
    fill_in "contact_title", with: title
    fill_in "Description", with: sentence
    click_button "Create Contact"
  end

  def then_i_can_view_it_on_gov_uk
    url = find_link(title)[:href]
    reload_url_until_status_code(url, 200)

    click_link title
    expect(page).to have_content(title)
    expect_url_matches_live_gov_uk
    expect_rendering_application("government-frontend")
  end
end
