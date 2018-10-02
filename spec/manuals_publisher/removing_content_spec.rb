feature "Removing content on Manuals Publisher", manuals_publisher: true do
  include ManualsPublisherHelpers

  let(:title) { "Removing a section from a manual #{SecureRandom.uuid}" }
  let(:section_title) { "How to eat an orange" }
  let(:section_slug) { "how-to-eat-an-orange" }

  scenario "Remove a section from a published manual" do
    given_there_is_a_published_manual_with_sections
    when_i_remove_a_section
    and_i_publish_the_manual
    then_the_removed_section_redirects_to_the_root_page
  end

  def signin_to_signon
    @user = signin_with_next_user(
      "Manuals Publisher" => %w[editor gds_editor],
    )
  end

  def given_there_is_a_published_manual_with_sections
    signin_to_signon if use_signon?

    create_draft_manual(title: title)
    @edit_manual_url = current_url

    create_manual_section
    create_manual_section(title: section_title)
    publish_manual

    contents_url = find_link("View on website")[:href]
    reload_url_until_status_code(contents_url, 200)
    reload_url_until_status_code(removed_section_url, 200)
  end

  def when_i_remove_a_section
    click_link section_title
    click_link "Withdraw section"

    fill_in "Change note", with: "Test removal"
    click_button "Yes"

    # This scenario currently raises a 500 error on the publisher app when withdrawing a section
    # The section does get marked as withdrawn before the form errors, so we reload the page after submitting
    #
    # See https://trello.com/c/hpkfiCU5/54-withdrawing-a-section-of-a-published-manual-returns-a-500 for the issue
    #   If this issue is now resolved this line + the ivar can be removed.
    visit @edit_manual_url
  end

  def and_i_publish_the_manual
    publish_manual
  end

  def then_the_removed_section_redirects_to_the_root_page
    url = find_link("View on website")[:href]

    reload_url_until_status_code(removed_section_url, 301, keep_retrying_while: [200])

    visit removed_section_url

    expect_rendering_application("manuals-frontend")
    expect(current_url).to eq(url)
    expect(page).to have_content(title)
    expect_url_matches_live_gov_uk
  end

  def removed_section_url
    contents_url = find_link("View on website")[:href]
    [contents_url, section_slug].join("/")
  end
end
