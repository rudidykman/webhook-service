# webhook-service

This service receives incoming JSON-formatted POST messages, processes the events, and sends them to Svix for further handling. It's designed to help customers react to asynchronous events by providing common HTTP webhooks.

This README provides basic instructions for setup and testing. See `NOTES.md` for my thoughts and design decisions.

## Setup

### Prerequisites:

In order to run this service, you will need to have [Ruby](https://www.ruby-lang.org/en/) and [Bundler](https://bundler.io/) installed.

You will also require a [Svix](https://www.svix.com/) account and API key.

### Install Dependencies:

Install the required dependencies using Bundler.
```
bundle install
```

### Configure Environment Variables:

Copy the .env.sample file to .env and add your Svix API key.

### Database Setup:

Set up the database by running migrations.
```
rake db:migrate
```

### Running the Service: 

Start the service by running the following command.

```
ruby app.rb
```
The service will start and listen for incoming requests on port 4567.

### Sending request:

Send JSON-formatted POST requests to the notifications endpoint (`/notifications`). The service will process the events and send them to Svix.

The `test` directory in the [original challenge repo](https://github.com/gigs-hiring/backend-challenge/tree/main) can also be used to send an array of requests to the service. Use `http://localhost:4567/notifications` as the service URL.

## Testing

### Automated test suite

You will need to create the test database before the first time you run the test suite. The easiest way to do this is to run the Active Record migration in the test environment
```
RACK_ENV=test rake db:migrate
```

Run the RSpec tests to ensure the functionality is working as expected.
```
bundle exec rspec
```
