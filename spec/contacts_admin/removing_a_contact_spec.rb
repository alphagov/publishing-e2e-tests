feature "Removing a contact", contacts_admin: true, finder_frontend: true, government_frontend: true do
  include ContactsHelpers

  let(:title) { "Removing a contact #{SecureRandom.uuid}" }

  scenario "Removing a contact" do
    given_there_is_a_published_contact
    when_i_remove_the_contact
    then_i_get_a_410_on_gov_uk
    and_it_is_not_shown_on_finder
  end

  private

  def signin_to_signon
    @user = signin_with_next_user(
      "Contacts Admin" => [],
    )
  end

  def given_there_is_a_published_contact
    signin_to_signon if use_signon?
    publish_contact(title: title)
    @url = find_link(title)[:href]
  end

  def when_i_remove_the_contact
    search_for_contact(title: title)
    click_link "Edit contact"

    page.accept_confirm do
      click_link "Delete"
    end
  end

  def then_i_get_a_410_on_gov_uk
    reload_url_until_status_code(@url, 410, keep_retrying_while: [404, 200])

    visit(@url)
    expect(page).to have_content(/gone/i)
  end

  def and_it_is_not_shown_on_finder
    contact_finder_url = Pathname.new(current_url).parent.to_s
    reload_url_until_match(contact_finder_url, :has_no_text?, title)
    visit contact_finder_url
    expect_rendering_application("finder-frontend")
    expect(page).to_not have_content(title)
  end
end
