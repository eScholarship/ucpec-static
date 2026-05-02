# frozen_string_literal: true

# Shared helpers and constants used by page generation scripts
# Require this file from generate_browse_pages.rb and generate_static_pages.rb

require "erb"
require "pathname"

include ERB::Util # rubocop:disable Style/MixinUsage

SITE_TITLE = "UC Press E-Books Collection, 1982-2004"
BRAND_NAME = "UC Press E-Books Collection, 1982-2004"
TEMPLATES  = Pathname.new(__dir__).join("templates")

def render(template_path, b)
  ERB.new(File.read(template_path), trim_mode: "-").result(b)
end

def render_with_layout(inner_template, b, css_file: nil, js_file: nil)
  b.local_variable_set(:page_content, render(inner_template, b))
  b.local_variable_set(:page_css,     Array(css_file).compact.map { |f| File.read(f) }.join("\n"))
  b.local_variable_set(:page_js,      js_file  ? File.read(js_file)  : "")
  b.local_variable_set(:base_css,     File.read(TEMPLATES.join("base.css")))
  render(TEMPLATES.join("_layout.html.erb"), b)
end
