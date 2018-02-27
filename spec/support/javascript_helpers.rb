module JavascriptHelpers
  def wait_for_jquery_ready_event
    ready_class_name = "e2e-jquery-ready-event"
    page.execute_script <<-JS
      $(function() {
        document.documentElement.className += " #{ready_class_name}";
      });
    JS
    find(".#{ready_class_name}")
  end

  def disable_jquery_transitions
    execute_script('$.support.transition = false')
  end
end
