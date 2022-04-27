feature "Archiving a Specialist subtopic on Collections Publisher", collections: true, collections_publisher: true do
  include CollectionsPublisherHelpers

  let(:parent_title) { unique_title }
  let(:parent_slug) { "archiving-collections-publisher-parent-#{SecureRandom.uuid}" }

  let(:subtopic_title) { unique_title }
  let(:subtopic_slug) { "archiving-collections-publisher-subtopic-#{SecureRandom.uuid}" }
  let(:link) { ["/topic", parent_slug, subtopic_slug].join("/") }

  scenario "Archiving a Specialist subtopic" do
    given_there_is_a_published_subtopic
    and_i_archive_it
    then_when_i_visit_the_subtopic_on_gov_uk_i_am_redirected_to_the_parent
  end

private

  def signin_to_signon
    signin_with_next_user("Collections Publisher" => ["GDS Editor"])
  end

  def given_there_is_a_published_subtopic
    signin_to_signon if use_signon?
    create_and_publish_parent_specialist_topic
    create_and_publish_subtopic
  end

  def and_i_archive_it
    click_link("Archive")
    select parent_title, from: "Choose a specialist topic to redirect to"
    click_button "Archive and redirect to a specialist topic"
    expect(page).to have_text(/archived/i)
  end

  def then_when_i_visit_the_subtopic_on_gov_uk_i_am_redirected_to_the_parent
    wait_for_the_subtopic_to_redirect

    window = window_opened_by { click_link(link) }
    within_window(window) do
      expect_rendering_application("collections")
      expect_url_matches_live_gov_uk
      expect(page).to have_content(parent_title)
      expect(current_url).to eq(@published_parent_url)
    end
  end

  def visit_create_specialist_topic
    visit_collections_publisher("/specialist-sector-pages/new")
  end

  def create_and_publish_parent_specialist_topic
    visit_create_specialist_topic

    fill_in_topic_form(slug: parent_slug, title: parent_title)
    click_button "Create"
    expect(page).to have_text(parent_title)
    @published_parent_url = find_link(parent_slug)[:href]
    publish_specialist_topic
  end

  def create_and_publish_subtopic
    visit_create_specialist_topic

    fill_in_topic_form(slug: subtopic_slug, title: subtopic_title, parent: parent_title)
    click_button "Create"
    expect(page).to have_text(subtopic_title)
    publish_specialist_topic
  end

  def publish_specialist_topic
    click_on("Publish")
    expect(page).to have_text(/published/i)
  end

  def wait_for_the_subtopic_to_redirect
    click_link(subtopic_title)
    url = find_link(link)[:href]
    reload_url_until_status_code(url, 301, keep_retrying_while: [200, 404])
  end
end
