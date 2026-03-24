#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates four static HTML browse pages from the books.json cache

# Usage:
# Fetch cache from S3 first:
# aws s3 cp s3://ucpec/data/books.json ./data/books.json

# Then generate pages:
# ruby generate_browse_pages.rb --books ./data/books.json --output-dir ./output

require "json"
require "erb"
require "optparse"
require "pathname"

include ERB::Util # rubocop:disable Style/MixinUsage

SITE_TITLE  = "UC Press E-Books Collection, 1982-2004"
BRAND_NAME  = "UC Press E-Books Collection, 1982-2004"
TEMPLATES   = Pathname.new(__dir__).join("templates")

def book_url(ark)
  # TODO: Update this to the new URL
  "http://ark.cdlib.org/ark:/13030/#{ark}/"
end

def pub_info(book)
  [book["publisher"], book["year"]].compact.reject(&:empty?).join(", ")
end

# Converts a subject string to a slug for use in HTML IDs
# (e.g. "Cinema and Performance Arts" -> "cinema-and-performance-arts")
def subject_slug(subject)
  subject.downcase.gsub(/[^a-z0-9]+/, "-").delete_prefix("-").delete_suffix("-")
end

def render(template_path, b)
  ERB.new(File.read(template_path), trim_mode: "-").result(b)
end

def render_with_layout(inner_template, css_file, b)
  b.local_variable_set(:page_content, render(inner_template, b))
  b.local_variable_set(:page_css,     File.read(css_file))
  b.local_variable_set(:base_css,     File.read(TEMPLATES.join("base.css")))
  render(TEMPLATES.join("_layout.html.erb"), b)
end

options = { books: "./data/books.json", output_dir: "./output" }

OptionParser.new do |opts|
  opts.banner = "Usage: ruby generate_browse_pages.rb [options]"
  opts.on("--books FILE",      "Path to books.json cache") { |v| options[:books] = v }
  opts.on("--output-dir DIR",  "Directory to write HTML files into") { |v| options[:output_dir] = v }
end.parse!

unless File.exist?(options[:books])
  warn "books.json not found at #{options[:books]}"
  warn "Fetch it first: aws s3 cp s3://ucpec/data/books.json #{options[:books]}"
  exit 1
end

all_books    = JSON.parse(File.read(options[:books]))
public_books = all_books.select { |b| b["public"] }

output_dir = Pathname.new(options[:output_dir])
output_dir.mkpath

warn "Loaded #{all_books.size} books (#{public_books.size} public)."

# Browse by Subject

subject_template = TEMPLATES.join("browse_subject.html.erb")
subject_css      = TEMPLATES.join("browse_subject.css")

[
  { file: "browse_subject_all.html",    books: all_books,    page_title: "Browse by Subject" },
  { file: "browse_subject_public.html", books: public_books, page_title: "Browse by Subject" }
].each do |variant|
  current_books = variant[:books]
  page_title    = variant[:page_title]

  subjects_map = Hash.new { |h, k| h[k] = [] }
  current_books.each do |book|
    book["subjects"].each { |s| subjects_map[s] << book }
  end
  subjects_map = subjects_map.sort.to_h

  html = render_with_layout(subject_template, subject_css, binding)
  output_dir.join(variant[:file]).write(html)
  warn "Wrote #{variant[:file]} (#{subjects_map.size} subjects)"
end

# Browse by Title

title_template = TEMPLATES.join("browse_title.html.erb")
title_css      = TEMPLATES.join("browse_title.css")

[
  { file: "browse_title_all.html",    books: all_books,    page_title: "Browse by Title" },
  { file: "browse_title_public.html", books: public_books, page_title: "Browse by Title" }
].each do |variant|
  current_books  = variant[:books].sort_by { |b| b["title_sort_key"] }
  page_title     = variant[:page_title]

  books_by_letter = current_books.group_by do |b|
    first = b["title_sort_key"].sub(/\A[^A-Z0-9]+/, "")[0]
    first&.match?(/[A-Z]/) ? first : "Other"
  end
  books_by_letter = books_by_letter.sort_by { |k, _| k == "Other" ? "\xFF" : k }.to_h
  active_letters  = books_by_letter.keys.reject { |k| k == "Other" }.sort
  has_other       = books_by_letter.key?("Other")
  all_letters     = ("A".."Z").to_a

  html = render_with_layout(title_template, title_css, binding)
  output_dir.join(variant[:file]).write(html)
  warn "Wrote #{variant[:file]} (#{current_books.size} titles)"
end

warn "\nDone. 4 pages written to #{output_dir}/"
