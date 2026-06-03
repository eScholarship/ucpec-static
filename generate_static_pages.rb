#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates static HTML pages (home, about, help) from ERB templates

# Usage:
# ruby generate_static_pages.rb --output-dir ./output

require "fileutils"
require "optparse"
require "pathname"
require_relative "shared_page_helpers"

options = { output_dir: "./output" }

OptionParser.new do |opts|
  opts.banner = "Usage: ruby generate_static_pages.rb [options]"
  opts.on("--output-dir DIR", "Directory to write HTML files into") { |v| options[:output_dir] = v }
end.parse!

output_dir = Pathname.new(options[:output_dir])
output_dir.mkpath

pages = [
  { filename: "index.html", template: "home.html.erb", title: "Home", css: "home.css" },
  { filename: "about.html", template: "about.html.erb", title: "About" },
  { filename: "help.html", template: "help.html.erb", title: "Help" },
  { filename: "403.html", template: "403.html.erb", title: "Access Restricted" }
]

pages.each do |page|
  page_title = page[:title]
  base_path  = ""
  css_file   = page[:css] ? TEMPLATES.join(page[:css]) : nil
  html = render_with_layout(TEMPLATES.join(page[:template]), binding, css_file: css_file)

  output_dir.join(page[:filename]).write(html)
  warn "Wrote #{page[:filename]}"
end

FileUtils.cp(Pathname.new(__dir__).join("data/publicTitles.txt"), output_dir.join("publicTitles.txt"))
warn "Copied publicTitles.txt"

warn "\nDone. #{pages.size} files written to #{output_dir}/"
