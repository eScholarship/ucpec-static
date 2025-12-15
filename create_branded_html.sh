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

# Read CSS content for inlining
CSS_FILE="templates/styles.css"
if [ ! -f "$CSS_FILE" ]; then
    echo "Warning: CSS file '$CSS_FILE' not found, proceeding without styles" >&2
    CSS_CONTENT=""
else
    CSS_CONTENT=$(<"$CSS_FILE")
fi

# Create the complete HTML document
cat << EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$SITE_TITLE</title>
  <style>
$CSS_CONTENT
  </style>
</head>
<body>
  <header class="site-header">
    <div class="container">
      <div>
        <h1 class="brand">$BRAND_NAME</h1>
        <div class="tagline">formerly eScholarship Editions</div>
      </div>
      <nav class="main-nav">
        <ul>
          <li><a href="#home">Home</a></li>
          <li><a href="#browse">Browse</a></li>
          <li><a href="#about">About</a></li>
        </ul>
      </nav>
    </div>
  </header>
  
  <main class="document-content">
    <div class="container">
      $TEI_CONTENT
    </div>
  </main>
  
  <footer class="site-footer">
    <div class="container">
      <div class="footer-links">
        <a href="#privacy">Privacy Policy</a>
        <a href="#terms">Terms of Use</a>
        <a href="#contact">Contact</a>
        <a href="#help">Help</a>
      </div>
      <p>$BRAND_NAME, is a joint publication of the <a href="https://cdlib.org">California Digital Library</a> and <a href="https://ucpress.edu">University of California Press</a>.</p>
      <p>&copy; 2025 The Regents of the University of California </p>
    </div>
  </footer>
</body>
</html>
EOF
