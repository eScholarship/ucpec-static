#!/bin/bash

# Script to create a branded HTML document from TEI XML
# Usage: ./create_branded_html.sh input.xml [site_title] [brand_name]

TEI_FILE="$1"
SITE_TITLE="${2:-TEI Document Viewer}"
BRAND_NAME="${3:-UCPEC}"

if [ -z "$TEI_FILE" ]; then
    echo "Usage: $0 <tei_file.xml> [site_title] [brand_name]"
    exit 1
fi

# Convert TEI to HTML fragment
TEI_CONTENT=$(docker run --rm -v "$(dirname "$(realpath "$TEI_FILE")"):/data" ucpec_static:latest exe/ucpec_static t 2h "/data/$(basename "$TEI_FILE")")

# Create the complete HTML document
cat << EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$SITE_TITLE</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    body {
      font-family: Georgia, serif;
      line-height: 1.6;
      color: #333;
      background-color: #f8f9fa;
    }
    
    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 0 20px;
    }
    
    .site-header {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 1.5rem 0;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }
    
    .site-header .container {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    
    .brand {
      font-size: 2rem;
      font-weight: bold;
      text-shadow: 0 2px 4px rgba(0,0,0,0.3);
    }
    
    .tagline {
      font-size: 0.9rem;
      opacity: 0.9;
      margin-top: 0.25rem;
    }
    
    [data-tei-tag="docImprint"] {
      display: flex;
      flex-direction: column;
    }
    
    .main-nav ul {
      list-style: none;
      display: flex;
      gap: 2rem;
    }
    
    .main-nav a {
      color: white;
      text-decoration: none;
      font-weight: 500;
      padding: 0.5rem 1rem;
      border-radius: 4px;
      transition: all 0.3s ease;
    }
    
    .main-nav a:hover {
      background: rgba(255,255,255,0.2);
      transform: translateY(-2px);
    }
    
    .document-content {
      background: white;
      margin: 3rem 0;
      padding: 4rem 0;
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
      border-radius: 8px;
    }
    
    .site-footer {
      background: #2c3e50;
      color: white;
      text-align: center;
      padding: 3rem 0;
    }
    
    .site-footer p {
      margin: 0.5rem 0;
    }
    
    .footer-links {
      margin: 1rem 0;
    }
    
    .footer-links a {
      color: #3498db;
      text-decoration: none;
      margin: 0 1rem;
    }
    
    .footer-links a:hover {
      text-decoration: underline;
    }
    
    /* TEI-specific styles */
    h1, h2, h3, h4, h5, h6 {
      margin: 2rem 0 1rem 0;
      color: #2c3e50;
    }
    
    h1 {
      font-size: 2.5rem;
      border-bottom: 3px solid #e74c3c;
      padding-bottom: 1rem;
    }
    
    h2 {
      font-size: 2rem;
      color: #3498db;
    }
    
    h3 {
      font-size: 1.5rem;
      color: #9b59b6;
    }
    
    p {
      margin: 1.5rem 0;
      text-align: justify;
    }
    
    .blockquote p,
    blockquote[data-tei-tag="epigraph"] {
      padding-left: 2rem;
      font-size: 0.9em;
    }
    
    .blockquote::before,
    .blockquote::after {
      content: none;
    }
    
    figure {
      margin: 2rem 0;
      text-align: center;
      padding: 1rem;
      background: #f8f9fa;
      border-radius: 8px;
    }
    
    figure img {
      max-width: 100%;
      height: auto;
      border-radius: 4px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    
    aside[data-type="footnote"] {
      background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
      border-left: 4px solid #6c757d;
      padding: 1.5rem;
      margin: 1.5rem 0;
      border-radius: 0 8px 8px 0;
      font-size: 0.9rem;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }

    aside[data-type="note"] {
      font-size: 0.9em;
      background-color: #ccc;
    }
    
    .Heading-Heading2B {
      color: #e74c3c;
      border-bottom: 2px solid #e74c3c;
      padding-bottom: 0.5rem;
    }
    
    .Heading-Heading3 {
      color: #3498db;
    }
    
    .Heading-Heading4 {
      color: #9b59b6;
    }
    
    .chapter-link {
      color: inherit;
      text-decoration: none;
    }
    
    .chapter-link:hover {
      text-decoration: underline;
    }
    
    /* Responsive design */
    @media (max-width: 768px) {
      .site-header .container {
        flex-direction: column;
        gap: 1rem;
      }
      
      .main-nav ul {
        gap: 1rem;
      }
      
      .document-content {
        margin: 1rem 0;
        padding: 2rem 0;
      }
      
      .container {
        padding: 0 15px;
      }
      
      h1 {
        font-size: 2rem;
      }
      
      h2 {
        font-size: 1.5rem;
      }
    }
  </style>
</head>
<body>
  <header class="site-header">
    <div class="container">
      <div>
        <h1 class="brand">$BRAND_NAME</h1>
        <div class="tagline">Digital Humanities Publishing Platform</div>
      </div>
      <nav class="main-nav">
        <ul>
          <li><a href="#home">Home</a></li>
          <li><a href="#browse">Browse</a></li>
          <li><a href="#search">Search</a></li>
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
      <p>&copy; 2025 $BRAND_NAME. All rights reserved.</p>
      <p>Powered by California Digital Library • TEI XML to HTML Converter</p>
    </div>
  </footer>
</body>
</html>
EOF
