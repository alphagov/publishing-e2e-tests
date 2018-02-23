feature "Updating published content from Publisher", publisher: true, frontend: true do
  include PublisherHelpers

  let(:title) { unique_title }
  let(:slug) { "updating-published-content-publisher-#{SecureRandom.uuid}" }

  scenario "Scheduling downtime for a transaction on Publisher" do
    given_there_is_a_published_transaction_artefact
    when_i_schedule_downtime_for_now_on_the_transaction
    and_i_visit_the_transaction_on_gov_uk
    then_the_downtime_message_is_shown
  end

  private

  def signin_to_signon
    @user = signin_with_next_user(
      "Publisher" => ["skip_review"],
    )
  end

  def given_there_is_a_published_transaction_artefact
    signin_to_signon if use_signon?
    create_publisher_artefact(slug: slug, title: title)
    publish_artefact

    @published_url = find_link("View this on the GOV.UK website")[:href]
    wait_for_artefact_to_be_viewable(@published_url)
  end

  def when_i_schedule_downtime_for_now_on_the_transaction
    visit_publisher("/downtimes")
    click_link(title)

    date = Date.today
    fill_in_schedule_downtime_form(date)

    @downtime_message = find_field("Message").value

    click_button "Schedule downtime message"

    expect(page).to have_text(title + " downtime message scheduled")
  end

  def and_i_visit_the_transaction_on_gov_uk
    url = find_link("/" + slug)[:href]
    reload_url_until_match(url, :has_text?, @downtime_message)
    click_link("/" + slug)
  end

  def then_the_downtime_message_is_shown
    expect(page).to have_text(@downtime_message)
  end
end
