module CollectionsPublisherHelpers
  def visit_collections_publisher(path = "/")
    visit(Plek.find("collections-publisher") + path)
  end

  def fill_in_topic_form(slug:, title:, parent: nil)
    select2(parent, from: "Parent") if parent

    fill_in "Slug", with: slug
    fill_in "Title", with: title
    fill_in "Description", with: sentence
  end

  def self.included(base)
    return unless SignonHelpers::use_signon?

    default_permissions = ['GDS Editor']

    base.before(:each) do |example|
      @user = get_next_user(
        "Collections Publisher" =>
        example.metadata.fetch(:permissions, default_permissions)
      )
      signin_with_user(@user)
    end
  end
end
