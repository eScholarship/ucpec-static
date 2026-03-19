#!/usr/bin/env ruby
# frozen_string_literal: true

# One-time script: parses all *.mets.xml files in a local directory and writes
# a books.json cache to S3 (or a local path for upload)

# Usage:
# ruby extract_books_metadata.rb --mets-dir ./tmp/book_files --output ./data/books.json

# Then upload the result:
# aws s3 cp ./data/books.json s3://ucpec/data/books.json

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
end

# Fallback parser for METS files that have only a mods dmdSec (no ucpress dmdSec)
# A handful of METS files were "built using MODS records provided by UCSD"
def parse_mets_mods_fallback(doc, mods)
  ark = doc.root["OBJID"].to_s.split("/").last.strip

  title_info = mods.at_xpath("mods:titleInfo", NS)
  title = [
    title_info&.at_xpath("mods:nonSort", NS)&.text,
    title_info&.at_xpath("mods:title", NS)&.text,
    title_info&.at_xpath("mods:subTitle", NS)&.text
  ].compact.join

  creator = mods.at_xpath("mods:name[@type='personal'][mods:role/mods:text='creator']", NS)
  author  = creator&.at_xpath("mods:namePart[not(@type)]", NS)&.text&.strip

  publisher = mods.at_xpath("mods:originInfo/mods:publisher", NS)&.text&.strip
  year      = mods.at_xpath("mods:originInfo/mods:dateIssued[@encoding='marc']", NS)&.text&.strip
  year    ||= mods.at_xpath("mods:originInfo/mods:dateIssued[not(@encoding)]", NS)&.text&.strip&.sub(/\Ac/, "")

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

  ark_full   = data_of(ucp, "ARK.ARK").to_s
  ark        = ark_full.split("/").last.to_s.strip

  title      = data_of(ucp, "UCPnum.Title")
  title_main = data_of(ucp, "UCPnum.TitleMain")
  author     = data_of(ucp, "UCPnum.AUTHOR_CITATION_FWD")
  public_val = text_of(ucp, "public_nonPublic")
  description = data_of(ucp, "UCPnum.Copy")
  author_bio  = data_of(ucp, "UCPnum.AuthorBioInCatalog")
  series      = data_of(ucp, "UCPnum.Series_name")

  subjects = (1..10).filter_map do |i|
    val = text_of(ucp, "SubDescs#{i}")
    val.gsub(" & ", " and ") unless val.nil? || val.empty?
  end.uniq

  publisher = mods&.at_xpath("mods:originInfo/mods:publisher", NS)&.text&.strip
  year      = mods&.at_xpath("mods:originInfo/mods:dateIssued[@encoding='marc']", NS)&.text&.strip
  year    ||= mods&.at_xpath("mods:originInfo/mods:dateIssued[not(@encoding)]", NS)&.text&.strip&.sub(/\Ac/, "")

  {
    "ark"            => ark,
    "title"          => title,
    "title_sort_key" => title_sort_key(title_main),
    "author"         => author,
    "subjects"       => subjects,
    "public"         => public_val == "Public",
    "publisher"      => publisher,
    "year"           => year,
    "description"    => description,
    "author_bio"     => author_bio,
    "series"         => series
  }
end

options = { mets_dir: "./tmp/book_files", output: "./data/books.json" }

OptionParser.new do |opts|
  opts.banner = "Usage: ruby extract_books_metadata.rb [options]"
  opts.on("--mets-dir DIR", "Directory containing downloaded METS files") { |v| options[:mets_dir] = v }
  opts.on("--output FILE", "Output path for books.json") { |v| options[:output] = v }
end.parse!

mets_files = Dir.glob(File.join(options[:mets_dir], "**", "*.mets.xml")).sort

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
warn "\nNext step: aws s3 cp #{output_path} s3://ucpec/data/books.json"
