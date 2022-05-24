feature "Publishing a parent Specialist topic and subtopic on Collections Publisher", collections: true, collections_publisher: true do
  include CollectionsPublisherHelpers

  let(:parent_title) { unique_title }
  let(:parent_slug) { "publishing-collections-publisher-parent-#{SecureRandom.uuid}" }
  let(:link) { "/topic/" + parent_slug }

  let(:subtopic_title) { unique_title }
  let(:subtopic_slug) { "publishing-collections-publisher-subtopic-#{SecureRandom.uuid}" }

  scenario "Publishing a parent Specialist topic page and a subtopic" do
    given_i_have_a_published_specialist_topic
    when_i_add_a_subtopic
    and_i_publish_it
    then_i_can_view_both_on_gov_uk
  end

private

  def signin_to_signon
    signin_with_next_user("Collections Publisher" => ["GDS Editor"])
  end

  def visit_create_specialist_topic
    visit_collections_publisher("/specialist-sector-pages/new")
  end

  def given_i_have_a_published_specialist_topic
    signin_to_signon if use_signon?
    create_specialist_topic
    and_i_publish_it
  end

  def create_specialist_topic
    visit_create_specialist_topic

    fill_in_topic_form(slug: parent_slug, title: parent_title)
    click_button "Create"
    expect(page).to have_text(parent_title)
  end

  def when_i_add_a_subtopic
    visit_create_specialist_topic

    fill_in_topic_form(slug: subtopic_slug, title: subtopic_title, parent: parent_title)
    click_button "Create"
    expect(page).to have_text(subtopic_title)
  end

  def and_i_publish_it
    click_on("Publish")
    expect(page).to have_text(/published/i)
  end

  def then_i_can_view_both_on_gov_uk
    url = find_link(link)[:href]
    reload_url_until_status_code(url, 200)

    window = window_opened_by { click_link(link) }
    within_window(window) do
      expect_rendering_application("collections")
      expect_url_matches_live_gov_uk
      expect(page).to have_content(subtopic_title)

      first(:link, parent_title).click
      expect_url_matches_live_gov_uk
      expect(current_url).to end_with(parent_slug)
    end
  end
end