# Production Dockerfile - excludes test/development gems for smaller image
# For CI/testing, use Dockerfile.ci instead
FROM ruby:3.4.6-alpine3.22

# Set the working directory inside the container
WORKDIR /app

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