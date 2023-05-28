FROM ruby:2.7

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

# Expose the port on which the Sinatra application will run
EXPOSE 3000

# Start the Sinatra application
CMD ["ruby", "app.rb", "-o", "0.0.0.0"]