feature "Publishing a topic on Collections Publisher", collections_publisher: true do

  let(:title) { title_with_timestamp }
  let(:slug) { slug_with_timestamp }
  let(:link) { "/topic/" + slug }

  scenario "Publishing a topic" do
    when_i_create_a_topic
    when_i_publish_it
    then_i_can_view_it_on_gov_uk
  end

  private

  def when_i_create_a_topic
    visit(Plek.find("collections-publisher") + "/topics/new")

    fill_in "Slug", with: slug
    fill_in "Title", with: title
    fill_in "Description", with: paragraph_with_timestamp

    click_button "Create"

    expect(page).to have_text(title)
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
    expect(page).to have_content(title)
  end
end
