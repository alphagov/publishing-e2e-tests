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
      within(".govuk-govspeak") do
        expect(page).to have_content(summary)
      end
    end
  end

  def expect_new_part(part_body)
    within(".govuk-govspeak") do
      expect(page).to have_content(part_body)
    end
  end

  def expect_file_attached
    reload_page_while_failing do
      expect(page).to have_link("Download map (PDF)")
      expect(page).to have_xpath("//img[contains(@src,'world_map.png')]")
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
