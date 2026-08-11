#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates sitemap.xml and robots.txt into the output directory
# The sitemap lists only publicly reachable URLs (access-restricted book and error pages are excluded)

# Usage:
# ruby generate_sitemap.rb --books ./data/books.json --output-dir ./output

require "json"
require "optparse"
require "pathname"
require_relative "shared_page_helpers"

# Static pages that should be discoverable by crawlers
STATIC_PATHS = %w[
  index.html
  about.html
  help.html
  browse_subject.html
  browse_title.html
  browse_author.html
].freeze

def public_book_path(book)
  "#{BASE_PATH}public/book/#{slugify(book["title"])}.html"
end

# Minimal XML escaping for the <loc> element
def xml_escape(str)
  str.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
end

options = { books: "./data/books.json", output_dir: "./output" }

OptionParser.new do |opts|
  opts.banner = "Usage: ruby generate_sitemap.rb [options]"
  opts.on("--books FILE",     "Path to books.json cache") { |v| options[:books] = v }
  opts.on("--output-dir DIR", "Directory to write files into") { |v| options[:output_dir] = v }
end.parse!

unless File.exist?(options[:books])
  warn "books.json not found at #{options[:books]}"
  exit 1
end

all_books   = JSON.parse(File.read(options[:books], encoding: "UTF-8"))
public_books = all_books.select { |b| b["public"] }

output_dir = Pathname.new(options[:output_dir])
output_dir.mkpath

# Build the ordered list of absolute URLs
urls = STATIC_PATHS.map { |p| absolute_url("#{BASE_PATH}#{p}") }
urls += public_books.map { |b| absolute_url(public_book_path(b)) }

# sitemap.xml
sitemap = +%(<?xml version="1.0" encoding="UTF-8"?>\n)
sitemap << %(<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n)
urls.each { |url| sitemap << "  <url>\n    <loc>#{xml_escape(url)}</loc>\n  </url>\n" }
sitemap << "</urlset>\n"

output_dir.join("sitemap.xml").write(sitemap)
warn "Wrote sitemap.xml (#{urls.size} URLs: #{STATIC_PATHS.size} static + #{public_books.size} public books)"

# robots.txt
robots = <<~ROBOTS
  User-agent: *
  Allow: #{BASE_PATH}
  Disallow: #{BASE_PATH}uc/
  Sitemap: #{absolute_url("#{BASE_PATH}sitemap.xml")}
ROBOTS

output_dir.join("robots.txt").write(robots)
warn "Wrote robots.txt"

warn "\nDone. 2 files written to #{output_dir}/"
