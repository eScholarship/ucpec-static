# ucpec-static

This project has two distinct responsibilities:

1. **Book pages** — converting TEI XML source files into HTML fragments that are served as individual book pages.
2. **Other static pages** — generating the site's browse, home, about, and help pages from ERB templates.

---

## Part 1: Book pages (TEI → HTML conversion)

Each book's page content is produced by converting a TEI XML file into an HTML fragment. This is handled by the `ucpec-static` gem executable and a set of shell scripts built on top of it.

### Running locally

Ensure you have the right Ruby version from `.ruby-version` (rbenv, mise, etc.), then bundle.

```bash
exe/ucpec-static t 2h path/to/tei.xml
```

### Docker

This project uses Docker for both development and production. There are two Dockerfiles:

- **`Dockerfile`** - Production image (smaller, no dev/test gems)
- **`Dockerfile.ci`** - CI/Development image (includes rubocop, rspec, all gems)

#### Building images

```bash
# Build production image
docker build -t ucpec_static:latest .

# Build CI/development image
docker build -f Dockerfile.ci -t ucpec_static:ci .
```

#### Converting a TEI file

```bash
docker run -v $(pwd)/data:/data ucpec_static:latest ./exe/ucpec_static tei to-html /data/your-file.xml
```

### Conversion scripts

Two shell scripts wrap the converter to produce complete, branded HTML documents:

#### `create_branded_html.sh`

Converts a single TEI XML file to a complete HTML document with header, footer, and styling.

```bash
./create_branded_html.sh input.xml [site_title] [brand_name]
```

```bash
./create_branded_html.sh data/document.xml "My Library" "UC Berkeley" > output.html
```

- `input.xml` — (Required) Path to the TEI XML file
- `site_title` — (Optional) Title for the HTML page (default: "TEI Document Viewer")
- `brand_name` — (Optional) Brand name for header (default: "UCPEC")

#### `batch_convert.sh`

Batch converts all TEI XML files in a directory to branded HTML documents.

```bash
./batch_convert.sh <input_directory> <output_directory> [site_title] [brand_name]
```

```bash
./batch_convert.sh data/ output/ "My Digital Library" "UC Berkeley"
```

- `input_directory` — (Required) Directory containing TEI XML files
- `output_directory` — (Required) Directory where HTML files will be saved
- `site_title` — (Optional) Title for HTML pages (default: "TEI Document Viewer")
- `brand_name` — (Optional) Brand name for headers (default: "UCPEC")

---

## Part 2: Other static pages

The site's browse, home, about, and help pages are generated from ERB templates by two Ruby scripts. All output is written into two subfolders of `--output-dir`: `public/` (publicly accessible content) and `uc/` (all content, for staff/internal use).

### Browse pages (`generate_browse_pages.rb`)

The browse pages are generated from `data/books.json`, a cached book catalog stored in S3. For normal usage you do not need to regenerate this cache, just fetch it from S3 and go straight to page generation.

#### Normal workflow: fetch the cache and generate pages

```bash
aws s3 cp s3://ucpec/data/books.json ./data/books.json --profile <profile>
```

```bash
ruby generate_browse_pages.rb \
  --books ./data/books.json \
  --output-dir ./output
```

This renders four HTML files using templates in `templates/`:

| Folder | File | Description |
|---|---|---|
| `public/` | `browse_subject.html` | Browse by subject — publicly accessible books only |
| `public/` | `browse_title.html` | Browse by title — publicly accessible books only |
| `uc/` | `browse_subject.html` | Browse by subject — all books |
| `uc/` | `browse_title.html` | Browse by title — all books |

#### Regenerating the metadata cache (only needed when source data changes)

If the underlying METS XML files in S3 have changed, sync them locally:

```bash
aws s3 sync s3://ucpec/book_files/ ./tmp/book_files/ \
  --exclude "*" \
  --include "*.mets.xml" \
  --profile <profile>
```

Parse them and write a new cache:

```bash
ruby extract_books_metadata.rb \
  --mets-dir ./tmp/book_files \
  --output ./data/books.json
```

After verifying the output, upload the updated cache back to S3 so others can use it:

```bash
aws s3 cp ./data/books.json s3://ucpec/data/books.json --profile <profile>
```

### Home, about, and help pages (`generate_static_pages.rb`)

```bash
ruby generate_static_pages.rb --output-dir ./output
```

This renders `index.html`, `about.html`, and `help.html` from templates in `templates/`, writing them into both `public/` and `uc/` under `--output-dir`.

---

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Running tests and linting

```bash
# Run all tests
docker run --rm -v $(pwd):/app ucpec_static:ci bundle exec rspec

# Run rubocop linter
docker run --rm -v $(pwd):/app ucpec_static:ci bundle exec rubocop

# Auto-fix linting issues
docker run --rm -v $(pwd):/app ucpec_static:ci bundle exec rubocop -A
```

### Pre-push checklist

- Run tests: `docker run --rm -v $(pwd):/app ucpec_static:ci bundle exec rspec`
- Run linter: `docker run --rm -v $(pwd):/app ucpec_static:ci bundle exec rubocop`
- Review changes: `git diff`
- Commit and push



## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eScholarship/ucpec_static. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/eScholarship/ucpec_static/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the UcpecStatic project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/eScholarship/ucpec_static/blob/main/CODE_OF_CONDUCT.md).