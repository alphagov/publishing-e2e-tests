feature "Unpublishing with Specialist Publisher", specialist_publisher: true, government_frontend: true do
  include SpecialistPublisherHelpers

  let(:title) { "Unpublishing Specialist Publisher #{SecureRandom.uuid}" }

  scenario "Unpublishing a DFID research output" do
    given_there_is_a_published_dfid_research_output
    when_i_unpublish_it
    then_i_receive_a_410_on_gov_uk
  end

  def signin_to_signon
    @user = signin_with_next_user(
      "Specialist Publisher" => %w[editor gds_editor],
    )
  end

  def given_there_is_a_published_dfid_research_output
    signin_to_signon if use_signon?
    visit_specialist_publisher("/dfid-research-outputs/new")

    fill_in_dfid_research_output_form(title: title)
    click_button("Save as draft")
    expect_created_alert(title)
    expect(page).to have_text(/Created #{Regexp.escape(title)}/), "Failed to create draft of #{title}"

    page.accept_confirm do
      click_button("Publish")
    end

    expect_published_alert(title)
    expect(page).to have_text(/Published #{Regexp.escape(title)}/), "Failed to publish #{title}"
  end

  def when_i_unpublish_it
    @url = find_link("View on website")[:href]
    reload_url_until_status_code(@url, 200, keep_retrying_while: 404)

    page.accept_confirm do
      click_button("Unpublish document")
    end

    expect_unpublished_alert(title)
  end

  def then_i_receive_a_410_on_gov_uk
    reload_url_until_status_code(@url, 410, keep_retrying_while: 200)

    visit(@url)
    expect_url_matches_live_gov_uk
    expect(page).to have_content(/gone/i)
  end
end
