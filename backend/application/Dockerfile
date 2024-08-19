FROM ruby:3.2

# Set the working directory in the container
WORKDIR /app

# Copy the Gemfile and Gemfile.lock to the container
COPY Gemfile ./

RUN if [ -f Gemfile.lock ]; then \
      cp Gemfile.lock ./ ; \
    fi

# Install dependencies
RUN bundle install

# Copy the application code to the container
COPY . .

RUN chmod +x entrypoint.sh

# Start the Sinatra application
CMD ["./entrypoint.sh"]