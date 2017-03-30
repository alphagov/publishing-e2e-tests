module TravelAdvicePublisherAssertionHelpers
  def expect_create_new_edition
    expect(page).to have_button("Create new edition")
  end

  def expect_new_edition(summary)
    reload_page_while_failing do
      expect(page).to have_content(summary)
    end
  end

  def expect_published_edition(summary)
    reload_page_while_failing do
      expect(page).to have_content(summary)
    end
  end

  def expect_new_part(part_body)
    within(".govuk-govspeak") do
      expect(page).to have_content(part_body)
    end
  end

  def expect_attachment_on_frontend
    reload_page_while_failing do
      expect(page).to have_link("Download map (PDF)")
      expect(page).to have_xpath("//img[contains(@src, 'example-image.jpg')]")
    end
  end

  def expect_example_file_downloaded
    reload_page_while_failing do
      expect(page).to have_current_path(/example-document.pdf/)
    end
  end

  def expect_draft_updated
    expect(find(".alert").text).to match(/updated/)
  end

  def expect_draft_published
    expect(find(".alert").text).to match(/published/)
  end

  RSpec.configuration.include TravelAdvicePublisherAssertionHelpers
end
