class SlidrInput < SimpleForm::Inputs::BooleanInput
  def input
    if nested_boolean_style?
      build_hidden_field_for_checkbox +
        template.label_tag(nil, class: "checkbox") {
          build_check_box_without_hidden_field + template.content_tag(:span, nil, html_options_for(:slidr, ['slidr'])) + inline_label
        }
    else
      build_check_box + template.content_tag(:span, nil, html_options_for(:slidr, ['slidr']))
    end
  end
  
  def label_input
    if options[:label] == false
      input
    elsif nested_boolean_style?
      html_options = label_html_options.dup
      html_options[:class].push(:checkbox)

      build_hidden_field_for_checkbox +
        @builder.label(label_target, html_options) {
          build_check_box_without_hidden_field + template.content_tag(:span, nil, html_options_for(:slidr, ['slidr'])) + label_text
        }
    else
      input + label
    end
  end
end