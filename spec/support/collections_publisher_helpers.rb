module CollectionsPublisherHelpers
  def visit_collections_publisher(path = "/")
    visit(Plek.find("collections-publisher") + path)
  end

  def fill_in_topic_form(slug:, title:, parent: nil)
    select2(topic_title, from: "Parent") if parent

    fill_in "Slug", with: slug
    fill_in "Title", with: title
    fill_in "Description", with: paragraph_with_timestamp
  end
end
