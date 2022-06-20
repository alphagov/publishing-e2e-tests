feature "Updating a contact", contacts_admin: true, finder_frontend: true, government_frontend: true do
  include ContactsHelpers

  let(:title) { "Updating a contact #{SecureRandom.uuid}" }
  let(:new_title) { "New title Updating a contact #{SecureRandom.uuid}" }
  let(:new_description) { "New description Updating a contact #{SecureRandom.uuid}" }

  scenario "Updating a contact" do
    given_there_is_a_published_contact
    when_i_update_the_contact
    then_i_can_view_it_on_gov_uk
    and_i_can_view_it_on_finder
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
    url = find_link(title)[:href]
    reload_url_until_status_code(url, 200)
  end

  def when_i_update_the_contact
    search_for_contact(title: title)

    click_link "Edit contact"
    fill_in "contact_title", with: new_title
    fill_in "Description", with: new_description
    click_button "Update Contact"
    click_link "Contacts", match: :first
  end

  def then_i_can_view_it_on_gov_uk
    url = find_link(new_title)[:href]
    reload_url_until_status_code(url, 200)
    reload_url_until_match(url, :has_text?, "Contact HM Revenue & Customs")

    click_link new_title
    expect_rendering_application("government-frontend")
    expect(page).to have_content(new_title)
    expect_url_matches_live_gov_uk
  end

  def and_i_can_view_it_on_finder
    contact_finder_url = find_link("Contact HM Revenue & Customs")[:href]
    reload_url_until_match(contact_finder_url, :has_text?, new_title)

    click_link "Contact HM Revenue & Customs"

    # I have used prior art from the Whitehall update spec to ensure this
    # test isn't flaky. The comment there says
    # "Session#find waits until an element appears
    # This seems to make a difference to the outcome of this spec"

    # Currently, it is unclear why this resolves the issue as the page is not
    # being dynamically rendered, therefore theoretically
    # waiting for an element to appear should not work.

    # Kevin Dew and I have discussed this and decided that we're going to
    # merge this despite not understanding why the fix works as it's a core
    # bit of functionality that is being tested and the bulk of the test behaves
    # as expected.

    # If this test begins to flake in future we can mark it as flaky as
    # outlined here https://github.com/alphagov/publishing-e2e-tests/blob/main/docs/troubleshooting.md#dealing-with-a-flaky-test

    find("a", text: new_title)

    expect_rendering_application("finder-frontend")
    expect(page).to have_content(new_title)
    expect(page).to have_content(new_description)
  end
end
