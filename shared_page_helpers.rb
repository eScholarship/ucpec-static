# frozen_string_literal: true

# Shared helpers and constants used by page generation scripts
# Require this file from generate_browse_pages.rb and generate_static_pages.rb

require "erb"
require "pathname"

include ERB::Util # rubocop:disable Style/MixinUsage

SITE_TITLE = "UC Press E-Books Collection, 1982-2004"
BRAND_NAME = "UC Press E-Books Collection, 1982-2004"
TEMPLATES  = Pathname.new(__dir__).join("templates")
BASE_PATH  = "/ucpressebooks/"
SITE_URL   = "https://publishing.cdlib.org"

# Joins an absolute site path (e.g. "/ucpressebooks/index.html") onto SITE_URL
def absolute_url(path)
  "#{SITE_URL}#{path.start_with?('/') ? path : "/#{path}"}"
end

# Converts a string to a URL/HTML-ID-safe slug
# (e.g. "Cinema and Performance Arts" -> "cinema-and-performance-arts")
def slugify(str)
  str.downcase.gsub(/[^a-z0-9]+/, "-").delete_prefix("-").delete_suffix("-")
end

def render(template_path, b)
  ERB.new(File.read(template_path), trim_mode: "-").result(b)
end

def render_with_layout(inner_template, b, css_file: nil, js_file: nil)
  b.local_variable_set(:page_content, render(inner_template, b))
  b.local_variable_set(:page_css,     Array(css_file).compact.map { |f| File.read(f) }.join("\n"))
  b.local_variable_set(:page_js,      js_file ? File.read(js_file) : "")
  b.local_variable_set(:base_css,     File.read(TEMPLATES.join("base.css")))
  render(TEMPLATES.join("_layout.html.erb"), b)
end
