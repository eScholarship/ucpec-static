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
  return nil if mods.nil?

  name = mods.at_xpath("mods:name[@type='personal']", NS)
  name&.at_xpath("mods:namePart", NS)&.text&.strip
end

def mods_year(origin)
  return nil if origin.nil?

  year = origin.at_xpath("mods:dateIssued[@encoding='marc']", NS)&.text&.strip
  year ||= origin.at_xpath("mods:dateIssued[not(@encoding)]", NS)&.text&.strip&.sub(/\Ac/, "")
  year
end

def mods_origin_fields(origin)
  publisher   = origin.at_xpath("mods:publisher", NS)&.text&.strip
  place       = origin.at_xpath("mods:place/mods:text", NS)&.text&.strip
  date_issued = origin.at_xpath("mods:dateIssued[not(@encoding)]", NS)&.text&.strip
  [publisher, place, date_issued]
end

def mods_origin_info(mods_node)
  origin = mods_node&.at_xpath("mods:originInfo", NS)
  return [nil, nil, nil, nil] if origin.nil?

  publisher, place, date_issued = mods_origin_fields(origin)
  [publisher, mods_year(origin), place, date_issued]
end

def parse_subjects(ucp)
  (1..10).filter_map do |i|
    val = text_of(ucp, "SubDescs#{i}")
    val.gsub(" & ", " and ") unless val.nil? || val.empty?
  end.uniq
end

# Types that are structural containers or decorative (excluded from the TOC)
EXCLUDED_TOC_TYPES = %w[TEI.2 text front body back dedication epigraph halftitle subtitle contents].freeze

# Parses the structMap to produce an ordered TOC array: [{"id" => ..., "label" => ...}]
def parse_toc(doc)
  struct = doc.at_css("structMap")
  return [] unless struct

  struct.css("div[LABEL]").filter_map do |div|
    next if EXCLUDED_TOC_TYPES.include?(div["TYPE"])

    fptr = div.at_css("fptr")
    next unless fptr

    file_id = fptr["FILEID"]
    next if file_id == "top"

    label = div["LABEL"].gsub(/[[:space:]]+/, " ").strip
    next if label.empty?

    { "id" => file_id, "label" => label }
  end
end

# Fallback parser for METS files that have only a mods dmdSec (no ucpress dmdSec)
# A handful of METS files were "built using MODS records provided by UCSD"
def parse_mets_mods_fallback(doc, mods)
  ark = doc.root["OBJID"].to_s.split("/").last.strip
  title = mods_title(mods)
  author = mods_author(mods)
  publisher, year, place, date_issued = mods_origin_info(mods)

  {
    "ark"             => ark,
    "title"           => title,
    "title_sort_key"  => title_sort_key(title),
    "author"          => author,
    "author_citation" => author,
    "subjects"        => [],
    "public"          => true,
    "publisher"       => publisher,
    "place"           => place,
    "year"            => year,
    "date_issued"     => date_issued,
    "description"     => nil,
    "toc"             => parse_toc(doc)
  }
end

def parse_mets(file)
  doc = Nokogiri::XML(File.read(file, encoding: "UTF-8"))

  ucp  = doc.at_xpath("//mets:dmdSec[@ID='ucpress']//cdl:ROW", NS)
  mods = doc.at_xpath("//mets:dmdSec[@ID='mods']//mods:mods", NS)

  return parse_mets_mods_fallback(doc, mods) if ucp.nil? && mods
  return nil if ucp.nil?

  ark = data_of(ucp, "ARK.ARK").to_s.split("/").last.to_s.strip
  publisher, year, place, date_issued = mods_origin_info(mods)

  {
    "ark"             => ark,
    "title"           => data_of(ucp, "UCPnum.Title"),
    "title_sort_key"  => title_sort_key(data_of(ucp, "UCPnum.TitleMain")),
    "author"          => mods_author(mods),
    "author_citation" => data_of(ucp, "UCPnum.AUTHOR_CITATION"),
    "subjects"        => parse_subjects(ucp),
    "public"          => text_of(ucp, "public_nonPublic") == "Public",
    "publisher"       => publisher,
    "place"           => place,
    "year"            => year,
    "date_issued"     => date_issued,
    "description"     => data_of(ucp, "UCPnum.Copy"),
    "toc"             => parse_toc(doc)
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
