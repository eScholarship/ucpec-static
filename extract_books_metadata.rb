#!/usr/bin/env ruby
# frozen_string_literal: true

# One-time script: parses all *.mets.xml files in a local directory and writes
# a books.json cache. After running, commit and push the updated file.

# Usage:
# ruby extract_books_metadata.rb --mets-dir ./tmp/book_files --output ./data/books.json

require "nokogiri"
require "json"
require "optparse"
require "pathname"

METS_NS = "http://www.loc.gov/METS/"
MODS_NS = "http://www.loc.gov/mods/"
CDL_NS  = "http://www.cdlib.org/schemas/xmldata"

NS = {
  "mets" => METS_NS,
  "mods" => MODS_NS,
  "cdl"  => CDL_NS
}.freeze

# Returns the text content of a direct child element (no DATA wrapper)
def text_of(node, tag)
  node.at_xpath("cdl:#{tag}", NS)&.text&.strip
end

# Returns the text content of a <DATA> child inside a CDL element
def data_of(node, tag)
  node.at_xpath("cdl:#{tag}/cdl:DATA", NS)&.text&.strip
end

# Strips leading articles and upcases for sort-stable alphabetical ordering
def title_sort_key(title_main)
  return "" if title_main.nil? || title_main.empty?

  title_main.upcase
    .sub(/^THE\s+/, "")
    .sub(/^AN\s+/, "")
    .sub(/^A\s+/, "")
    .sub(/\A[^A-Z0-9]+/, "")
end

def mods_title(mods)
  title_info = mods.at_xpath("mods:titleInfo", NS)
  [
    title_info&.at_xpath("mods:nonSort", NS)&.text,
    title_info&.at_xpath("mods:title", NS)&.text,
    title_info&.at_xpath("mods:subTitle", NS)&.text
  ].compact.join
end

def mods_author(mods)
  creator = mods.at_xpath("mods:name[@type='personal'][mods:role/mods:text='creator']", NS)
  creator&.at_xpath("mods:namePart[not(@type)]", NS)&.text&.strip
end

def mods_year(origin)
  return nil if origin.nil?

  year = origin.at_xpath("mods:dateIssued[@encoding='marc']", NS)&.text&.strip
  year ||= origin.at_xpath("mods:dateIssued[not(@encoding)]", NS)&.text&.strip&.sub(/\Ac/, "")
  year
end

def mods_publisher_year(mods_node)
  origin = mods_node&.at_xpath("mods:originInfo", NS)
  publisher = origin&.at_xpath("mods:publisher", NS)&.text&.strip
  [publisher, mods_year(origin)]
end

def parse_subjects(ucp)
  (1..10).filter_map do |i|
    val = text_of(ucp, "SubDescs#{i}")
    val.gsub(" & ", " and ") unless val.nil? || val.empty?
  end.uniq
end

# Fallback parser for METS files that have only a mods dmdSec (no ucpress dmdSec)
# A handful of METS files were "built using MODS records provided by UCSD"
def parse_mets_mods_fallback(doc, mods)
  ark = doc.root["OBJID"].to_s.split("/").last.strip
  title = mods_title(mods)
  author = mods_author(mods)
  publisher, year = mods_publisher_year(mods)

  {
    "ark"            => ark,
    "title"          => title,
    "title_sort_key" => title_sort_key(title),
    "author"         => author,
    "subjects"       => [],
    "public"         => true,
    "publisher"      => publisher,
    "year"           => year,
    "description"    => nil,
    "author_bio"     => nil,
    "series"         => nil
  }
end

def parse_mets(file)
  doc = Nokogiri::XML(File.read(file, encoding: "UTF-8"))

  ucp  = doc.at_xpath("//mets:dmdSec[@ID='ucpress']//cdl:ROW", NS)
  mods = doc.at_xpath("//mets:dmdSec[@ID='mods']//mods:mods", NS)

  return parse_mets_mods_fallback(doc, mods) if ucp.nil? && mods
  return nil if ucp.nil?

  ark = data_of(ucp, "ARK.ARK").to_s.split("/").last.to_s.strip
  publisher, year = mods_publisher_year(mods)

  {
    "ark"            => ark,
    "title"          => data_of(ucp, "UCPnum.Title"),
    "title_sort_key" => title_sort_key(data_of(ucp, "UCPnum.TitleMain")),
    "author"         => data_of(ucp, "UCPnum.AUTHOR_CITATION_FWD"),
    "subjects"       => parse_subjects(ucp),
    "public"         => text_of(ucp, "public_nonPublic") == "Public",
    "publisher"      => publisher,
    "year"           => year,
    "description"    => data_of(ucp, "UCPnum.Copy"),
    "author_bio"     => data_of(ucp, "UCPnum.AuthorBioInCatalog"),
    "series"         => data_of(ucp, "UCPnum.Series_name")
  }
end

options = { mets_dir: "./tmp/book_files", output: "./data/books.json" }

OptionParser.new do |opts|
  opts.banner = "Usage: ruby extract_books_metadata.rb [options]"
  opts.on("--mets-dir DIR", "Directory containing downloaded METS files") { |v| options[:mets_dir] = v }
  opts.on("--output FILE", "Output path for books.json") { |v| options[:output] = v }
end.parse!

mets_files = Dir.glob(File.join(options[:mets_dir], "**", "*.mets.xml"))

if mets_files.empty?
  warn "No .mets.xml files found under #{options[:mets_dir]}"
  exit 1
end

warn "Parsing #{mets_files.size} METS files..."

books = mets_files.filter_map do |file|
  result = parse_mets(file)
  if result.nil?
    warn "  Skipped (no usable dmdSec): #{file}"
  else
    warn "  OK: #{result["ark"]} — #{result["title"]}"
  end
  result
end

books.sort_by! { |b| b["title_sort_key"] }

output_path = Pathname.new(options[:output])
output_path.dirname.mkpath
output_path.write(JSON.pretty_generate(books))

warn "\nWrote #{books.size} books to #{output_path}"
