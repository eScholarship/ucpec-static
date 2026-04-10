#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates static HTML browse pages from the books.json cache
# Outputs two folder variants:
# <output-dir>/public/ - public books only
# <output-dir>/uc/ - all books (staff/internal use)

# Usage:
# ruby generate_browse_pages.rb --books ./data/books.json --output-dir ./output

require "json"
require "optparse"
require "pathname"
require_relative "shared_page_helpers"

def book_url(book)
  "book/#{slugify(book["title"])}.html"
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
  warn "books.json not found at #{options[:books]}
  exit 1
end

all_books    = JSON.parse(File.read(options[:books]))
public_books = all_books.select { |b| b["public"] }

base_dir = Pathname.new(options[:output_dir])

variants = [
  { dir: base_dir.join("public"), books: public_books },
  { dir: base_dir.join("uc"),     books: all_books }
]

variants.each { |v| v[:dir].mkpath }

warn "Loaded #{all_books.size} books (#{public_books.size} public)."

# Browse by Subject

subject_template = TEMPLATES.join("browse_subject.html.erb")
subject_css      = TEMPLATES.join("browse_subject.css")

variants.each do |variant|
  current_books = variant[:books]
  page_title    = "Browse by Subject"
  base_path     = ""

  subjects_map = Hash.new { |h, k| h[k] = [] }
  current_books.each do |book|
    book["subjects"].each { |s| subjects_map[s] << book }
  end
  subjects_map = subjects_map.sort.to_h

  html = render_with_layout(subject_template, binding, css_file: subject_css)
  variant[:dir].join("browse_subject.html").write(html)
  warn "Wrote #{variant[:dir].basename}/browse_subject.html (#{subjects_map.size} subjects)"
end

# Browse by Title

title_template = TEMPLATES.join("browse_title.html.erb")
title_css      = TEMPLATES.join("browse_title.css")

variants.each do |variant|
  current_books = variant[:books].sort_by { |b| b["title_sort_key"] }
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

  html = render_with_layout(title_template, binding, css_file: title_css)
  variant[:dir].join("browse_title.html").write(html)
  warn "Wrote #{variant[:dir].basename}/browse_title.html (#{current_books.size} titles)"
end

warn "\nDone. 4 pages written to #{base_dir}/ (public/ and uc/)"
