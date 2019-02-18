feature "Archiving a child topic on Collections Publisher", collections: true, collections_publisher: true do
  include CollectionsPublisherHelpers

  let(:parent_title) { unique_title }
  let(:parent_slug) { "archiving-collections-publisher-parent-#{SecureRandom.uuid}" }

  let(:child_title) { unique_title }
  let(:child_slug) { "archiving-collections-publisher-child-#{SecureRandom.uuid}" }
  let(:link) { ["/topic", parent_slug, child_slug].join("/") }

  scenario "Archiving a child specialist sector" do
    given_there_is_a_published_child_topic
    and_i_archive_it
    then_when_i_visit_the_child_on_gov_uk_i_am_redirected_to_the_parent
  end

private

  def signin_to_signon
    signin_with_next_user("Collections Publisher" => ["GDS Editor"])
  end

  def given_there_is_a_published_child_topic
    signin_to_signon if use_signon?
    create_and_publish_parent_topic
    create_and_publish_child_topic
  end

  def and_i_archive_it
    click_link("Archive")
    select2(parent_title, from: "Choose a specialist sector to redirect to")
    click_button "Archive and redirect to a specialist sector"
    expect(page).to have_text("archived")
  end

  def then_when_i_visit_the_child_on_gov_uk_i_am_redirected_to_the_parent
    wait_for_the_child_to_redirect

    window = window_opened_by { click_link(link) }
    within_window(window) do
      expect_rendering_application("collections")
      expect_url_matches_live_gov_uk
      expect(page).to have_content(parent_title)
      expect(current_url).to eq(@published_parent_url)
    end
  end

  def visit_create_topic
    visit_collections_publisher("/specialist-sector-pages/new")
  end

  def create_and_publish_parent_topic
    visit_create_topic

    fill_in_topic_form(slug: parent_slug, title: parent_title)
    click_button "Create"
    expect(page).to have_text(parent_title)
    @published_parent_url = find_link(parent_slug)[:href]
    publish_topic
  end

  def create_and_publish_child_topic
    visit_create_topic

    fill_in_topic_form(slug: child_slug, title: child_title, parent: parent_title)
    click_button "Create"
    expect(page).to have_text(child_title)
    publish_topic
  end

  def publish_topic
    click_link("Publish")
    expect(page).to have_text("published")
  end

  def wait_for_the_child_to_redirect
    click_link(child_title)
    url = find_link(link)[:href]
    reload_url_until_status_code(url, 301, keep_retrying_while: [200])
  end
end
