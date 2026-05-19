#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates static HTML browse pages from the books.json cache
# The browse pages list all books so users can discover the full catalog

# Usage:
# ruby generate_browse_pages.rb --books ./data/books.json --output-dir ./output

require "json"
require "optparse"
require "pathname"
require_relative "shared_page_helpers"

def book_url(book)
  prefix = book["public"] ? "public" : "uc"
  "/ucpressebooks/#{prefix}/book/#{slugify(book["title"])}.html"
end

def pub_info(book)
  [book["publisher"], book["year"]].compact.reject(&:empty?).join(", ")
end

# Converts a string to a URL/HTML-ID-safe slug
# (e.g. "Cinema and Performance Arts" -> "cinema-and-performance-arts")
def slugify(str)
  str.downcase.gsub(/[^a-z0-9]+/, "-").delete_prefix("-").delete_suffix("-")
end

options = { books: "./data/books.json", output_dir: "./output" }

OptionParser.new do |opts|
  opts.banner = "Usage: ruby generate_browse_pages.rb [options]"
  opts.on("--books FILE",      "Path to books.json cache") { |v| options[:books] = v }
  opts.on("--output-dir DIR",  "Directory to write HTML files into") { |v| options[:output_dir] = v }
end.parse!

unless File.exist?(options[:books])
  warn "books.json not found at #{options[:books]}"
  exit 1
end

all_books = JSON.parse(File.read(options[:books]))

output_dir = Pathname.new(options[:output_dir])
output_dir.mkpath

warn "Loaded #{all_books.size} books."

# Browse by Subject

subject_template = TEMPLATES.join("browse_subject.html.erb")
subject_css      = TEMPLATES.join("browse_subject.css")
browse_shared_css = TEMPLATES.join("browse_shared.css")
browse_filter_js = TEMPLATES.join("browse_filter.js")

current_books = all_books
page_title    = "Browse by Subject"
base_path     = ""

subjects_map = Hash.new { |h, k| h[k] = [] }
current_books.each do |book|
  book["subjects"].each { |s| subjects_map[s] << book }
end
subjects_map = subjects_map.sort.to_h

html = render_with_layout(subject_template, binding, css_file: [browse_shared_css, subject_css], js_file: browse_filter_js)
output_dir.join("browse_subject.html").write(html)
warn "Wrote browse_subject.html (#{subjects_map.size} subjects)"

# Browse by Title

title_template = TEMPLATES.join("browse_title.html.erb")
title_css      = TEMPLATES.join("browse_title.css")

current_books = all_books.sort_by { |b| b["title_sort_key"] }
page_title    = "Browse by Title"
base_path     = ""

books_by_letter = current_books.group_by do |b|
  first = b["title_sort_key"].sub(/\A[^A-Z0-9]+/, "")[0]
  first&.match?(/[A-Z]/) ? first : "Other"
end
books_by_letter = books_by_letter.sort_by { |k, _| k == "Other" ? "\xFF" : k }.to_h
active_letters  = books_by_letter.keys.reject { |k| k == "Other" }.sort
has_other       = books_by_letter.key?("Other")
all_letters     = ("A".."Z").to_a

html = render_with_layout(title_template, binding, css_file: [browse_shared_css, title_css], js_file: browse_filter_js)
output_dir.join("browse_title.html").write(html)
warn "Wrote browse_title.html (#{current_books.size} titles)"

# Browse by Author

author_template = TEMPLATES.join("browse_author.html.erb")
author_css      = TEMPLATES.join("browse_author.css")

page_title = "Browse by Author"
base_path  = ""

# Build an ordered map of author -> books, skipping entries with no author
authors_map = Hash.new { |h, k| h[k] = [] }
all_books.each do |book|
  author = book["author"]
  next if author.nil? || author.strip.empty?
  authors_map[author] << book
end
authors_map = authors_map.sort_by { |author, _| author.upcase }.to_h

# Group authors by first letter of their name
authors_by_letter = {}
authors_map.each do |author, books|
  first = author.upcase[0]
  letter = first&.match?(/[A-Z]/) ? first : "Other"
  authors_by_letter[letter] ||= []
  authors_by_letter[letter] << [author, books]
end
authors_by_letter = authors_by_letter.sort_by { |k, _| k == "Other" ? "\xFF" : k }.to_h
active_letters    = authors_by_letter.keys.reject { |k| k == "Other" }.sort
has_other         = authors_by_letter.key?("Other")
all_letters       = ("A".."Z").to_a

html = render_with_layout(author_template, binding, css_file: [browse_shared_css, author_css], js_file: browse_filter_js)
output_dir.join("browse_author.html").write(html)
warn "Wrote browse_author.html (#{authors_map.size} authors)"

warn "\nDone. 3 pages written to #{output_dir}/"
