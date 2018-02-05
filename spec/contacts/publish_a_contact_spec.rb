feature "Publishing a contact", contacts: true, finder_frontend: true, government_frontend: true do
  include ContactsHelpers

  let(:title) { "Creating a contact #{SecureRandom.uuid}" }

  scenario "Creating a contact" do
    when_i_create_a_contact
    then_i_can_view_it_on_gov_uk
    and_i_can_view_it_on_finder
  end

  def when_i_create_a_contact
    publish_contact(title: title)
  end

  def then_i_can_view_it_on_gov_uk
    url = find_link(title)[:href]
    reload_url_until_status_code(url, 200)
    reload_url_until_match(url, :has_text?, "Contact HMRC")

    click_link title
    expect(page).to have_content(title)
    expect_url_matches_live_gov_uk
    expect_rendering_application("government-frontend")
  end

  def and_i_can_view_it_on_finder
    contact_finder_url = find_link("Contact HMRC")[:href]
    reload_url_until_match(contact_finder_url, :has_text?, title)

    click_link "Contact HMRC"
    expect_rendering_application("finder-frontend")
    expect(page).to have_content(title)
  end
end
