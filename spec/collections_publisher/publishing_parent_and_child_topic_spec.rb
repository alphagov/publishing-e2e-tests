feature "Publishing a parent and child topic on Collections Publisher", collections_publisher: true do
  include CollectionsPublisherHelpers

  let(:topic_title) { title_with_timestamp }
  let(:topic_slug) { slug_with_timestamp }
  let(:link) { "/topic/" + topic_slug }

  let(:child_slug) { slug_with_timestamp }
  let(:child_title) { title_with_timestamp }

  scenario "Publishing a parent and child topic" do
    when_i_create_a_topic
    when_i_publish_it
    when_i_create_a_child_topic
    when_i_publish_it
    then_i_can_view_it_on_gov_uk
  end

  private

  def visit_create_topic
    visit_collections_publisher("/topics/new")
  end

  def when_i_create_a_topic
    visit_create_topic

    fill_in_topic_form(slug: topic_slug, title: topic_title)
    click_button "Create"
    expect(page).to have_text(topic_title)
  end

  def when_i_create_a_child_topic
    visit_create_topic

    fill_in_topic_form(slug: child_slug, title: child_title, parent: topic_title)
    click_button "Create"
    expect(page).to have_text(child_title)
  end

  def when_i_publish_it
    click_link("Publish topic")
    expect(page).to have_text("published")
  end

  def then_i_can_view_it_on_gov_uk
    url = find_link(link)[:href]
    reload_url_until_status_code(url, 200)

    click_link(link)
    expect_rendering_application("collections")
    expect(page).to have_content(child_title)
  end
end
