# Production Dockerfile - excludes test/development gems for smaller image
# For CI/testing, use Dockerfile.ci instead
FROM ruby:3.4.6-alpine3.22

# Set the working directory inside the container
WORKDIR /app

# Increase fiber VM stack size to handle deeply nested XML documents.
# Ruby's default fiber stack (128KB) overflows when recursively extracting
# TEI nodes for large files via dry-effects fiber-based effect handlers.
ENV RUBY_FIBER_VM_STACK_SIZE=8388608

RUN     apk update && \ 
        apk add --no-cache git alpine-sdk yaml-dev libffi-dev sqlite-dev

# Copy the app exwecpt 
COPY . . 

# Install Ruby gems (production only)
RUN bundle install --without development test

# Set the entry point to run your Ruby script
# ENTRYPOINT ["exe/ucpec-static"]

# Or, if you want to allow arguments to be passed to your script
CMD ["exe/ucpec-static"]