feature "Discarding a draft on Specialist Publisher", specialist_publisher: true do
  include SpecialistPublisherHelpers

  let(:title) { title_with_timestamp }

  scenario "Discarding a draft CMA case" do
    given_there_is_a_draft_cma_case
    when_i_discard_it
    then_i_get_a_410_on_draft_gov_uk
  end

  def given_there_is_a_draft_cma_case
    visit_specialist_publisher("/cma-cases/new")

    fill_in_cma_case_form(title: title)

    click_button("Save as draft")
    expect_created_alert(title)
  end

  def when_i_discard_it
    @url = find_link("Preview draft")[:href]

    page.accept_confirm do
      click_button("Discard draft")
    end

    expect_discarded_draft_alert(title)
  end

  def then_i_get_a_410_on_draft_gov_uk
    # Keep retrying while 200, as the page might have not been
    # discarded yet. Keep retrying while 404, as while the content
    # store deletes the routes before deleting the content, the
    # reloading of the routes by the router is asynchronous, so there
    # is the opportunity to get a 404 when the router still sends the
    # request to Specialist Publisher, and the Content Store no longer
    # has the content.
    #
    # TODO: To avoid this test failing before the release of the
    # Content Store with the change described above, make this test
    # temporarily more permissive, accepting the previous and new
    # behaviours. Once the Content Store is deployed, the status codes
    # ([404, 410]) should be changed to 410 only.
    reload_url_until_status_code(@url, [404, 410], keep_retrying_while: [200, 404])
  end
end
