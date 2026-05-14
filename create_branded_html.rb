#!/usr/bin/env ruby
# frozen_string_literal: true

# Creates a single, branded HTML document from a TEI XML file

# Step 1: Convert TEI XML to an HTML fragment (via ucpec_static)
# Step 2: Wrap the fragment in the shared layout template

# Usage:
#   ruby create_branded_html.rb --input tei/ft0000032w.xml
#   ruby create_branded_html.rb --input tei/ft0000032w.xml > book.html

require "open3"
require "optparse"
require "pathname"
require_relative "shared_page_helpers"

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby create_branded_html.rb --input FILE"
  opts.on("--input FILE", "TEI XML input file") { |v| options[:input] = v }
end.parse!

unless options[:input]
  warn "Error: --input FILE is required"
  exit 1
end

input = Pathname.new(options[:input])
abort "File not found: #{input}" unless input.exist?

# Step 1: Convert TEI XML -> HTML fragment (with citation injected by the converter)
input_dir  = input.realpath.dirname.to_s
input_file = "/data/#{input.basename}"
books_json = Pathname.new(__dir__).join("data/books.json").realpath.to_s
tei_content, status = Open3.capture2(
  "docker", "run", "--rm",
  "-v", "#{input_dir}:/data",
  "-v", "#{books_json}:/data/books.json:ro",
  "ucpec_static:latest",
  "exe/ucpec_static", "t", "2h", "--books", "/data/books.json", input_file.to_s
)
abort "Conversion failed for #{input}" unless status.success?

# Step 2: Wrap in the shared layout template
page_title = nil
base_path  = ""
book_css   = TEMPLATES.join("styles.css")

html = render_with_layout(TEMPLATES.join("book.html.erb"), binding, css_file: book_css)

print html
