class ThemedFormBuilder < ActionView::Helpers::FormBuilder
  # Delegate common methods to the template for access to helpers
  delegate :content_tag, :tag, :safe_join, to: :@template

  # Standard input field with consistent styling
  def text_field(method, options = {})
    field_wrapper(method, options) do
      styled_input_field(method, options) do
        styled_options = prepare_input_options(method, options)
        super(method, styled_options)
      end
    end
  end

  # Standard text area with consistent styling
  def text_area(method, options = {})
    field_wrapper(method, options) do
      styled_input_field(method, options) do
        styled_options = prepare_input_options(method, options)
        super(method, styled_options)
      end
    end
  end

  # Standard email field with consistent styling
  def email_field(method, options = {})
    field_wrapper(method, options) do
      styled_input_field(method, options) do
        styled_options = prepare_input_options(method, options)
        super(method, styled_options)
      end
    end
  end

  # Standard password field with consistent styling
  def password_field(method, options = {})
    field_wrapper(method, options) do
      styled_input_field(method, options) do
        styled_options = prepare_input_options(method, options)
        super(method, styled_options)
      end
    end
  end

  # Standard number field with consistent styling
  def number_field(method, options = {})
    field_wrapper(method, options) do
      styled_input_field(method, options) do
        styled_options = prepare_input_options(method, options)
        super(method, styled_options)
      end
    end
  end

  # Standard select field with consistent styling
  def select(method, choices = nil, options = {}, html_options = {}, &block)
    field_wrapper(method, html_options) do
      styled_input_field(method, html_options) do
        styled_html_options = prepare_input_options(method, html_options)
        super(method, choices, options, styled_html_options, &block)
      end
    end
  end

  # Standard collection select with consistent styling
  def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
    field_wrapper(method, html_options) do
      styled_input_field(method, html_options) do
        styled_html_options = prepare_input_options(method, html_options)
        super(method, collection, value_method, text_method, options, styled_html_options)
      end
    end
  end

  # Standard submit button with theme styling
  def submit(value = nil, options = {})
    style = options.delete(:style) || :primary
    css_classes = submit_classes(style, options)
    super(value, options.merge(class: css_classes))
  end

  private

  # Prepare options hash with styled classes for input fields
  def prepare_input_options(method, options = {})
    styled_options = options.dup
    styled_options[:class] = input_classes(options.merge(method: method))
    styled_options.delete(:method) # Remove our internal method parameter
    styled_options
  end

  # Wrapper for each form field with label and error handling
  def field_wrapper(method, options = {}, &block)
    wrapper_classes = "mb-4"
    wrapper_classes += " #{options.delete(:wrapper_class)}" if options[:wrapper_class]

    content_tag :div, class: wrapper_classes do
      safe_join([
        field_label(method, options),
        block.call,
        field_errors(method)
      ].compact)
    end
  end

  # Generate label for the field
  def field_label(method, options = {})
    label_text = options.delete(:label)
    return if label_text == false

    label_text ||= method.to_s.humanize
    label_classes = "block text-lg font-medium text-baby-powder-50 mb-2"

    label(method, label_text, class: label_classes)
  end

  # Wrapper for input field styling
  def styled_input_field(method, options = {}, &block)
    content_tag :div, class: "relative" do
      block.call
    end
  end

  # Display validation errors for the field
  def field_errors(method)
    return unless object&.errors&.key?(method)

    errors = object.errors[method]
    return if errors.empty?

    content_tag :div, class: "mt-1" do
      safe_join(errors.map do |error|
        content_tag :p, error, class: "text-sm text-red-cmyk-400"
      end)
    end
  end

  # Standard input field CSS classes
  def input_classes(options = {})
    base_classes = [
      "block", "w-full", "rounded-md", "px-3", "py-2",
      "text-baby-powder-50", "bg-rich-black-800",
      "border", "border-bright-turquoise-600",
      "focus:border-bright-turquoise-400", "focus:ring-1", "focus:ring-bright-turquoise-400",
      "focus:outline-none", "transition-colors",
      "placeholder-baby-powder-400"
    ]

    # Add error classes if field has errors
    method_name = options[:method]
    if method_name && object&.errors&.key?(method_name)
      base_classes += [ "border-red-cmyk-500", "focus:border-red-cmyk-400", "focus:ring-red-cmyk-400" ]
    end

    existing_classes = options[:class]

    # Handle different class formats (string, array, or array with conditionals)
    if existing_classes.present?
      if existing_classes.is_a?(String)
        all_classes = base_classes + [ existing_classes ]
      else
        # Handle arrays and complex class structures by using Rails' token_list helper
        processed_classes = @template.token_list(existing_classes)
        all_classes = base_classes + [ processed_classes ]
      end
    else
      all_classes = base_classes
    end

    all_classes.compact.join(" ")
  end

  # Submit button CSS classes based on theme
  def submit_classes(style, options = {})
    base_classes = [
      "rounded-md", "px-4", "py-2", "font-medium", "transition-colors",
      "focus:outline-none", "focus:ring-2", "focus:ring-offset-2",
      "disabled:opacity-50", "disabled:cursor-not-allowed"
    ]

    style_classes = case style
    when :primary
      [
        "bg-red-violet-700", "hover:bg-red-violet-600", "text-baby-powder-50",
        "focus:ring-red-violet-500"
      ]
    when :danger
      [
        "bg-red-cmyk-600", "hover:bg-red-cmyk-500", "text-baby-powder-50",
        "focus:ring-red-cmyk-500"
      ]
    when :secondary
      [
        "bg-rich-black-700", "hover:bg-rich-black-600", "text-baby-powder-50",
        "border", "border-bright-turquoise-600", "focus:ring-bright-turquoise-500"
      ]
    else # default
      [
        "bg-slate-500", "hover:bg-slate-600", "text-baby-powder-50",
        "focus:ring-slate-500"
      ]
    end

    existing_classes = options[:class]
    all_classes = base_classes + style_classes

    # Handle different class formats safely
    if existing_classes.present?
      if existing_classes.is_a?(String)
        all_classes << existing_classes
      else
        # Handle arrays and complex class structures
        processed_classes = @template.token_list(existing_classes)
        all_classes << processed_classes
      end
    end

    all_classes.compact.join(" ")
  end
end
