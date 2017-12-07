feature "Publishing content from Publisher to Frontend", publisher: true, frontend: true do
  include PublisherHelpers

  let(:title) { title_with_timestamp }
  let(:slug) { slug_with_timestamp }
  let(:subpart_title) { title_with_timestamp }

  scenario "Publishing an artefact" do
    given_there_is_a_draft_artefact_with_subpage
    and_i_publish_it
    then_i_can_view_the_artefact_on_gov_uk
    and_i_can_view_the_subpage_on_gov_uk
  end

  private

  def given_there_is_a_draft_artefact_with_subpage
    create_publisher_artefact(slug: slug, title: title, format: "Guide")
    add_part_to_artefact(title: title_with_timestamp)
    @subpart_slug = add_part_to_artefact(title: subpart_title)
  end

  def and_i_publish_it
    publish_artefact
  end

  def then_i_can_view_the_artefact_on_gov_uk
    wait_for_artefact_to_be_published

    click_link("View this on the GOV.UK website")
    expect(page).to have_content(title)
    expect_url_matches_live_gov_uk
  end

  def and_i_can_view_the_subpage_on_gov_uk
    visit(subpage_url)
    expect(page).to have_content(subpart_title)
    expect_url_matches_live_gov_uk
  end

  def wait_for_artefact_to_be_published
    @published_url = find_link("View this on the GOV.UK website")[:href]
    wait_for_artefact_to_be_viewable(@published_url)
  end

  def subpage_url
    [@published_url, @subpart_slug].join("/")
  end
end
