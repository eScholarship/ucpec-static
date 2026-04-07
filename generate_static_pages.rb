#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates static HTML pages (home, about, help) from ERB templates

# Usage:
# ruby generate_static_pages.rb --output-dir ./output

require "optparse"
require "pathname"
require_relative "shared_page_helpers"

options = { output_dir: "./output" }

OptionParser.new do |opts|
  opts.banner = "Usage: ruby generate_static_pages.rb [options]"
  opts.on("--output-dir DIR", "Directory to write HTML files into") { |v| options[:output_dir] = v }
end.parse!

base_dir    = Pathname.new(options[:output_dir])
output_dirs = [base_dir.join("public"), base_dir.join("uc")]

output_dirs.each(&:mkpath)

pages = [
  { filename: "index.html", template: "home.html.erb", title: "Home" },
  { filename: "about.html", template: "about.html.erb", title: "About" },
  { filename: "help.html", template: "help.html.erb", title: "Help" }
]

pages.each do |page|
  page_title = page[:title]
  base_path  = ""
  html = render_with_layout(TEMPLATES.join(page[:template]), binding)

  output_dirs.each do |dir|
    dir.join(page[:filename]).write(html)
    warn "Wrote #{dir.basename}/#{page[:filename]}"
  end
end

warn "\nDone. #{pages.size * output_dirs.size} files written to #{base_dir}/ (public/ and uc/)"
