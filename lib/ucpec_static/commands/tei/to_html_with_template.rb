# frozen_string_literal: true

module UCPECStatic
  module Commands
    module TEI
      # Extended command that wraps TEI HTML output in a branded template
      class ToHtmlWithTemplate < UCPECStatic::AbstractCommand
        desc "Convert a single TEI document to HTML with branded template"

        argument :tei_path, required: true, desc: "The path to the TEI XML file to process",
          type: :string

        option :template_path, required: false, desc: "Path to HTML template file",
          type: :string, aliases: %w[-t]
        
        option :site_title, required: false, desc: "Site title for the template",
          type: :string, default: "TEI Document Viewer"
        
        option :brand_name, required: false, desc: "Brand name for header",
          type: :string, default: "UCPEC"

        runs_job! UCPECStatic::TEI::HTMLConversion::Job

        # @param [StringIO] sio
        def on_success!(sio)
          tei_html = sio.string.strip
          
          if template_path && File.exist?(template_path)
            # Use custom template
            template_content = File.read(template_path)
            final_html = inject_into_template(template_content, tei_html)
          else
            # Use default template
            final_html = wrap_with_default_template(tei_html)
          end
          
          write_raw! final_html
        end

        private

        def inject_into_template(template, content)
          template.gsub('{{TEI_CONTENT}}', content)
                  .gsub('{{SITE_TITLE}}', site_title)
                  .gsub('{{BRAND_NAME}}', brand_name)
        end

        def wrap_with_default_template(content)
          <<~HTML
            <!DOCTYPE html>
            <html lang="en">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>#{site_title}</title>
              <style>
                #{default_css}
              </style>
            </head>
            <body>
              <header class="site-header">
                <div class="container">
                  <h1 class="brand">#{brand_name}</h1>
                  <nav class="main-nav">
                    <ul>
                      <li><a href="#home">Home</a></li>
                      <li><a href="#about">About</a></li>
                      <li><a href="#search">Search</a></li>
                    </ul>
                  </nav>
                </div>
              </header>
              
              <main class="document-content">
                <div class="container">
                  #{content}
                </div>
              </main>
              
              <footer class="site-footer">
                <div class="container">
                  <p>&copy; 2024 #{brand_name}. All rights reserved.</p>
                  <p>Powered by UCPEC Static</p>
                </div>
              </footer>
            </body>
            </html>
          HTML
        end

        def default_css
          <<~CSS
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
              background: #2c3e50;
              color: white;
              padding: 1rem 0;
              box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
            
            .site-header .container {
              display: flex;
              justify-content: space-between;
              align-items: center;
            }
            
            .brand {
              font-size: 1.8rem;
              font-weight: bold;
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
              transition: color 0.3s ease;
            }
            
            .main-nav a:hover {
              color: #3498db;
            }
            
            .document-content {
              background: white;
              margin: 2rem 0;
              padding: 3rem 0;
              box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            }
            
            .site-footer {
              background: #34495e;
              color: white;
              text-align: center;
              padding: 2rem 0;
            }
            
            .site-footer p {
              margin: 0.5rem 0;
            }
            
            h1, h2, h3, h4, h5, h6 {
              margin: 2rem 0 1rem 0;
              color: #2c3e50;
            }
            
            p {
              margin: 1rem 0;
            }
            
            blockquote {
              border-left: 4px solid #3498db;
              padding-left: 2rem;
              margin: 2rem 0;
              font-style: italic;
              color: #555;
            }
            
            figure {
              margin: 2rem 0;
              text-align: center;
            }
            
            figure img {
              max-width: 100%;
              height: auto;
            }
            
            aside[data-type="footnote"] {
              background: #f8f9fa;
              border: 1px solid #dee2e6;
              padding: 1rem;
              margin: 1rem 0;
              border-radius: 4px;
              font-size: 0.9rem;
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
          CSS
        end
      end
    end
  end
end


