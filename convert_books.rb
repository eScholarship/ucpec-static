#!/usr/bin/env ruby
# frozen_string_literal: true

# Batch-converts TEI XML files to branded HTML pages in two steps:
# Step 1: Convert all TEI XML → HTML fragments
# Step 2: Wrap each fragment in the shared layout template

# Output structure:
#   <output-dir>/public/book/<title-slug>.html
#   <output-dir>/uc/book/<title-slug>.html

# Usage:
#   ruby convert_books.rb --input-dir ./tei --output-dir ./output
#   ruby convert_books.rb --input-dir ./tei --output-dir ./output --workers 8

# If only the layout/CSS changed (not the TEI source), skip the
# conversion and re-use the cached fragments in tmp/fragments/:
#   ruby convert_books.rb --output-dir ./output --skip-conversion

require "json"
require "optparse"
require "pathname"
require_relative "shared_page_helpers"

def title_slug(title)
  title.downcase.gsub(/[^a-z0-9]+/, "-").delete_prefix("-").delete_suffix("-")
end

options = { input_dir: "./tei", output_dir: "./output", books: "./data/books.json", workers: 4, skip_conversion: false }

OptionParser.new do |opts|
  opts.banner = "Usage: ruby convert_books.rb [options]"
  opts.on("--input-dir DIR", "Directory of TEI XML files (default: ./tei)") { |v| options[:input_dir] = v }
  opts.on("--output-dir DIR", "Base output directory (default: ./output)") { |v| options[:output_dir] = v }
  opts.on("--books FILE", "Path to books.json cache (default: ./data/books.json)") { |v| options[:books] = v }
  opts.on("--workers N", "Number of parallel workers (default: 4)", Integer) { |v| options[:workers] = v }
  opts.on("--skip-conversion", "Skip Step 1 and re-use existing tmp/fragments/ cache") { options[:skip_conversion] = true }
end.parse!

unless File.exist?(options[:books])
  abort "books.json not found at #{options[:books]}."
end

books_by_ark = JSON.parse(File.read(options[:books])).each_with_object({}) do |book, h|
  h[book["ark"]] = book
end

input_dir    = Pathname.new(options[:input_dir]).realpath
base_dir     = Pathname.new(options[:output_dir])
uc_book_dir  = base_dir.join("uc", "book")
pub_book_dir = base_dir.join("public", "book")
fragment_dir = Pathname.new("tmp/fragments")

[uc_book_dir, pub_book_dir, fragment_dir].each(&:mkpath)

# Step 1: TEI -> HTML fragments (xargs -P inside a single Docker container)
# Skip with --skip-conversion to re-use cached fragments when only the layout changed

if options[:skip_conversion]
  abort "No cached fragments found in #{fragment_dir}. Run without --skip-conversion first." if fragment_dir.glob("*.html").empty?
  warn "Skipping Step 1: using cached fragments from #{fragment_dir}/"
else
  tei_count = input_dir.glob("*.xml").size
  abort "No XML files found in #{input_dir}" if tei_count.zero?

  warn "Step 1: Converting #{tei_count} TEI files to HTML fragments (#{options[:workers]} workers)..."

  # spawn parallel processes (xargs -P) inside the container
  # each process is a separate exe/ucpec_static invocation but shares
  # the container's filesystem
  ok = system(
    "docker", "run", "--rm",
    "-v", "#{input_dir}:/data/input",
    "-v", "#{fragment_dir.realpath}:/data/output",
    "-v", "#{Pathname.new(options[:books]).realpath}:/data/books.json:ro",
    "ucpec_static:latest",
    "sh", "-c",
    "ls /data/input/*.xml | xargs -P #{options[:workers]} -I {} " \
    "sh -c 'name=$(basename \"$1\" .xml); exe/ucpec_static t 2h --books /data/books.json \"$1\" > \"/data/output/$name.html\" && echo \"$name\" >&2' _ {}"
  )

  abort "Docker conversion failed" unless ok

  warn "Step 1 complete: #{fragment_dir.glob('*.html').size}/#{tei_count} fragments generated.\n"
end

# Step 2: Wrap fragments in the branded layout template

fragments = fragment_dir.glob("*.html").sort
warn "Step 2: Wrapping #{fragments.size} fragments in layout template..."

book_css = TEMPLATES.join("styles.css")

public_count = 0
skipped      = 0

fragments.each_with_index do |fragment, i|
  ark  = fragment.basename(".html").to_s
  book = books_by_ark[ark]

  unless book
    warn "[#{i + 1}/#{fragments.size}] SKIPPED #{ark} (not found in books.json)"
    skipped += 1
    next
  end

  slug     = title_slug(book["title"])
  filename = "#{slug}.html"

  tei_content = fragment.read
  page_title  = nil
  base_path   = BASE_PATH
  html = render_with_layout(TEMPLATES.join("book.html.erb"), binding, css_file: book_css)

  # All books go into uc/
  uc_book_dir.join(filename).write(html)

  # Public books also go into public/
  if book["public"]
    pub_book_dir.join(filename).write(html)
    public_count += 1
  end

  label = book["public"] ? "public+uc" : "uc-only"
  warn "[#{i + 1}/#{fragments.size}] #{slug}.html (#{label})"
end

total = fragments.size - skipped
warn "\nDone. #{total} books written to #{base_dir}/ " \
     "(uc (all): #{total}, public: #{public_count}, skipped: #{skipped})"
