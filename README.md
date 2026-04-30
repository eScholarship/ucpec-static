# ucpec-static

This project has two distinct responsibilities:

1. **Book pages** — converting TEI XML source files into HTML fragments that are served as individual book pages.
2. **Other static pages** — generating the site's browse, home, about, and help pages from ERB templates.

---

## Full site generation workflow

**1. Build the Docker image** (required for TEI → HTML conversion)

```bash
docker build -t ucpec_static:latest .
```

**2. Convert book pages**

```bash
ruby convert_books.rb --input-dir ./tei --output-dir ./output
```

**3. Generate browse pages**

```bash
ruby generate_browse_pages.rb --books ./data/books.json --output-dir ./output
```

**4. Generate static pages** (home, about, help)

```bash
ruby generate_static_pages.rb --output-dir ./output
```

**5. Deploy to S3**

```bash
# Dry run first to review changes
./deploy.sh --profile <profile> --env stg

# Then execute
./deploy.sh --profile <profile> --env stg --execute
```

On subsequent runs, the Docker image only needs to be rebuilt if the gem code changes.

---

## Part 1: Book pages (TEI → HTML conversion)

Each book's page content is produced by converting a TEI XML file into an HTML fragment. This is handled by the `ucpec-static` gem executable and Ruby scripts built on top of it.

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

Two Ruby scripts wrap the converter to produce complete, branded HTML documents:

#### `create_branded_html.rb`

Converts a single TEI XML file to a complete HTML document with header, footer, and styling.

```bash
ruby create_branded_html.rb --input tei/ft0000032w.xml
```

- `--input FILE` — (Required) Path to the TEI XML file

#### `convert_books.rb`

Batch converts all TEI XML files in a directory to branded HTML documents, wrapping each fragment in the shared layout template. Output is written to `<output-dir>/uc/book/` (all books) and `<output-dir>/public/book/` (public books only).

```bash
# Normal run
ruby convert_books.rb --input-dir ./tei --output-dir ./output

# With more parallel workers
ruby convert_books.rb --input-dir ./tei --output-dir ./output --workers 8

# Re-wrap only (skip TEI conversion, reuse cached fragments in tmp/fragments/)
ruby convert_books.rb --output-dir ./output --skip-conversion
```

Options:

- `--input-dir DIR` — Directory of TEI XML files (default: `./tei`)
- `--output-dir DIR` — Base output directory (default: `./output`)
- `--books FILE` — Path to books.json cache (default: `./data/books.json`)
- `--workers N` — Number of parallel workers (default: 4)
- `--skip-conversion` — Skip TEI→fragment step and reuse existing `tmp/fragments/` cache

#### Fragment cache (`tmp/fragments/`)

During Step 1, `convert_books.rb` writes one HTML fragment per TEI file into `tmp/fragments/` (e.g. `tmp/fragments/ft0000032w.html`). These are the raw converter outputs — no layout, no CSS, and named by ARK.

The cache is useful when you only change the layout template or CSS and don't need to re-run the slow Docker conversion step. Pass `--skip-conversion` to go straight to Step 2 and re-wrap the existing fragments.

The `tmp/` directory is gitignored, fragments are ephemeral build artifacts.

---

## Part 2: Other static pages

The site's browse, home, about, and help pages are generated from ERB templates by two Ruby scripts. Output is written directly into `--output-dir` (not into the `public/` or `uc/` subfolders, which only contain book pages).

### Browse pages (`generate_browse_pages.rb`)

Generates browse pages from `data/books.json`.

```bash
ruby generate_browse_pages.rb --books ./data/books.json --output-dir ./output
```

This renders two HTML files using templates in `templates/`:

| File | Description |
|---|---|
| `browse_subject.html` | Browse by subject — all books |
| `browse_title.html` | Browse by title — all books |

Both pages list the full catalog with clean URLs (e.g. `book/slug.html`). CloudFront routes users to the appropriate folder (`public/` or `uc/`) based on credentials.

Options:

- `--books FILE` — Path to books.json cache (default: `./data/books.json`)
- `--output-dir DIR` — Base output directory (default: `./output`)

#### Updating the metadata cache

You'll need to regenerate `books.json` whenever:

- The underlying METS XML files in S3 have changed (updated records, external requests, etc.)
- You want to extract additional metadata fields from the METS files (e.g. adding a new attribute to the `Book` structure in `extract_books_metadata.rb`)
- You make any other changes to the shape or content of `books.json` — downstream scripts (`convert_books.rb`, `generate_browse_pages.rb`) all read from this cache, so any structural change requires a fresh file

First, sync the METS XML files from S3 locally:

```bash
aws s3 sync s3://ucpec/book_files/ ./tmp/book_files/ \
  --exclude "*" \
  --include "*.mets.xml" \
  --profile <profile>
```

Then parse them and write a new cache:

```bash
ruby extract_books_metadata.rb \
  --mets-dir ./tmp/book_files \
  --output ./data/books.json
```

After verifying the output, commit the updated file and push so others can use it.

Options:

- `--mets-dir DIR` — Directory containing downloaded METS files (default: `./tmp/book_files`)
- `--output FILE` — Output path for books.json (default: `./data/books.json`)

### Home, about, and help pages (`generate_static_pages.rb`)

```bash
ruby generate_static_pages.rb --output-dir ./output
```

Renders `index.html`, `about.html`, and `help.html` from templates in `templates/`, writing them directly into `--output-dir`.

Options:

- `--output-dir DIR` — Base output directory (default: `./output`)

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