#!/bin/bash

# Script to create a branded HTML document from TEI XML
# Usage: ./create_branded_html.sh input.xml [site_title] [brand_name]

TEI_FILE="$1"
SITE_TITLE="${2:-UC Press E-Books Collection, 1982-2004}"
BRAND_NAME="${3:-UC Press E-Books Collection, 1982-2004}"

if [ -z "$TEI_FILE" ]; then
    echo "Usage: $0 <tei_file.xml> [site_title] [brand_name]"
    exit 1
fi

# Convert TEI to HTML fragment
TEI_CONTENT=$(docker run --rm -v "$(dirname "$(realpath "$TEI_FILE")"):/data" ucpec_static:latest exe/ucpec_static t 2h "/data/$(basename "$TEI_FILE")")

# Render the shared layout template, CSS is read from files inside Ruby
export SITE_TITLE BRAND_NAME
ruby -r erb -e "
  include ERB::Util
  SITE_TITLE = ENV['SITE_TITLE']
  BRAND_NAME = ENV['BRAND_NAME']
  base_css    = File.read('templates/base.css') rescue ''
  page_css    = File.read('templates/styles.css') rescue ''
  page_title  = nil
  tei_content = STDIN.read
  page_content = %(<main class=\"document-content\">\n    <div class=\"container\">\n      #{tei_content}\n    </div>\n  </main>)
  print ERB.new(File.read('templates/_layout.html.erb'), trim_mode: '-').result(binding)
" <<< "$TEI_CONTENT"
