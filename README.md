# ucpec-static

An executable for processing TEI XML to HTML fragments in a bespoke fashion.

## Usage

To run locally, ensure that you have the right Ruby version from `.ruby-version` (rbenv, mise, etc). Then bundle.

```bash
exe/ucpec-static t 2h path/to/tei.xml
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Docker Development

Copy TEI files into the `./data` directory

This project uses Docker for both development and production. There are two Dockerfiles:

- **`Dockerfile`** - Production image (smaller, no dev/test gems)
- **`Dockerfile.ci`** - CI/Development image (includes rubocop, rspec, all gems)

#### Building Images

```bash
# Build production image
docker build -t ucpec_static:latest .

# Build CI/development image
docker build -f Dockerfile.ci -t ucpec_static:ci .
```

#### Converting TEI Files

```bash
# Convert a single TEI file to HTML
docker run -v $(pwd)/data:/data ucpec_static:latest ./exe/ucpec_static tei to-html /data/your-file.xml
```

#### Running Tests and Linting

```bash
# Run all tests
docker run --rm -v $(pwd):/app ucpec_static:ci bundle exec rspec

# Run rubocop linter
docker run --rm -v $(pwd):/app ucpec_static:ci bundle exec rubocop

# Auto-fix linting issues
docker run --rm -v $(pwd):/app ucpec_static:ci bundle exec rubocop -A
```

### Conversion Scripts

Two shell scripts are provided for converting TEI files with branding:

#### `create_branded_html.sh`

Converts a single TEI XML file to a complete HTML document with header, footer, and styling.

**Usage:**
```bash
./create_branded_html.sh input.xml [site_title] [brand_name]
```

**Example:**
```bash
./create_branded_html.sh data/document.xml "My Library" "UC Berkeley" > output.html
```

**Parameters:**
- `input.xml` - (Required) Path to the TEI XML file
- `site_title` - (Optional) Title for the HTML page (default: "TEI Document Viewer")
- `brand_name` - (Optional) Brand name for header (default: "UCPEC")

#### `batch_convert.sh`

Batch converts multiple TEI XML files in a directory to branded HTML documents.

**Usage:**
```bash
./batch_convert.sh <input_directory> <output_directory> [site_title] [brand_name]
```

**Example:**
```bash
./batch_convert.sh data/ output/ "My Digital Library" "UC Berkeley"
```

**Parameters:**
- `input_directory` - (Required) Directory containing TEI XML files
- `output_directory` - (Required) Directory where HTML files will be saved
- `site_title` - (Optional) Title for HTML pages (default: "TEI Document Viewer")
- `brand_name` - (Optional) Brand name for headers (default: "UCPEC")

### Development Workflow

**Pre-Push Checklist:**
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