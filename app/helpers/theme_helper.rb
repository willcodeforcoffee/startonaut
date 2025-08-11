module ThemeHelper
  THEME_LINK_CLASSES = [ "rounded-md", "px-4", "py-2", "block", "font-medium" ].freeze
  THEME_LINK_STYLES = {
    default: [ "bg-slate-500", "hover:bg-slate-600", "text-baby-powder-50" ].freeze,
    primary: [ "bg-red-violet-700", "hover:bg-red-violet-600", "text-baby-powder-50" ].freeze,
    danger:  [ "bg-red-cmyk-600", "hover:bg-red-cmyk-500", "text-baby-powder-50" ].freeze
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
end
