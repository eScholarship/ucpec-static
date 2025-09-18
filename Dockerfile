# Use an official Ruby image as the base
FROM ruby:3.4.6-alpine3.22

# Set the working directory inside the container
WORKDIR /app

RUN     apk update && \ 
        apk add --no-cache git alpine-sdk

# Copy the app exwecpt 
COPY . . 

# Install Ruby gems
RUN bundle install --without development test

# Set the entry point to run your Ruby script
# ENTRYPOINT ["exe/ucpec-static"]

# Or, if you want to allow arguments to be passed to your script
CMD ["exe/ucpec-static"]