module ThemeHelper
  THEME_LINK_CLASSES = [ "rounded-md", "px-4", "py-2", "block", "w-fit", "font-medium" ].freeze
  THEME_LINK_STYLES = {
    default: [ "bg-white", "hover:bg-neutral-600", "text-black", "border-gray-900" ].freeze,
    primary: [ "bg-blue-400", "hover:bg-blue-400", "text-black" ].freeze,
    secondary: [ "bg-bright-turquoise-800", "hover:bg-bright-turquoise-700", "text-baby-powder-50" ].freeze,
    danger:  [ "bg-red-600", "hover:bg-red-500", "text-baby-powder-50" ].freeze
}.freeze

  def theme_link_to(name, path, options = {})
    css_classes = THEME_LINK_CLASSES + THEME_LINK_STYLES[options[:style] || :default]
    options[:class] = [ css_classes, options[:class] ].compact.join(" ")
    options.delete(:style)

    link_to(name, path, options)
  end

  # Dynamically generate methods for each theme style
  THEME_LINK_STYLES.each_key do |style_key|
    define_method "#{style_key}_link_to" do |name, path, options = {}|
      theme_link_to(name, path, options.merge(style: style_key))
    end
  end

  def theme_button_to(name, path, options = {})
    css_classes = THEME_LINK_CLASSES + THEME_LINK_STYLES[options[:style] || :default]
    options[:class] = [ css_classes, options[:class] ].compact.join(" ")
    options.delete(:style)

    button_to(name, path, options)
  end

  # Dynamically generate methods for each theme style
  THEME_LINK_STYLES.each_key do |style_key|
    define_method "#{style_key}_button_to" do |name, path, options = {}|
      theme_button_to(name, path, options.merge(style: style_key))
    end
  end
end
