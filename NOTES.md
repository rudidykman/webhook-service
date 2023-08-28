# Notes

Firstly, thank you for taking the time to review my submission!

This file contains notes on my thinking and decision making while working on the Gigs Backend Challenge, and answers to questions posed in the challenge.

## Language & Framework

The first decision I made was to use Ruby, as it is quick and easy to get a new service started and I have experience working with Ruby.

Next, I decided to use [Sinatra](https://sinatrarb.com/) as a web framework, again because it is very quick and easy to use when create a new web application, and I felt that Rails would be too bulky for a service that would only contain a single endpoint. This decision came with some drawbacks, as I ended up spending some time adding additional gems (like ActiveRecord) that would have come out of the box with Rails, but I still think it is a suitable choice for the application. I don't have previous experience with Sinatra, so it was also fun for me to learning something new while completing the challenge.

## App structure

It would have been possible to solve the challenge without making use of a database, as [Svix supports idempotency](https://docs.svix.com/idempotency). However, I decided to add a database layer to the service, as I wanted to create a separate application on Svix for each Gigs project, and it is useful to keep track of events sent to Svix and any subsequent failures.

I structured the domain entities in my service to closely match the Svix entities that I made use of, namely `Notification` (which maps 1-1 to a Svix `message`) and `Application` (which maps 1-1 to a Svix `application`). I decided to implement the validation in the database, so the models barely contain anything. I have made use of ActiveRecord, as it does all the heavy lifting for you. As such, the models are (intuitively) located in `models/`.

I decided to include a service layer to contain all the business logic. This makes the service easy to understand and test. The services are located in `services/`.

The single endpoint (`POST /notifications`) is in the main `app.rb` file. This only does some basic request validation (using [json_schemer](https://github.com/davishmcclurg/json_schemer) to validate the incoming request body against the provided event JSON schema), calls the service, and then formats the response. I added custom error classes in `lib/errors.rb` to make it easy to handle and format errors.

## Svix Rate Limiting

I decided to ignore the requirement to handle Svix rate limit errors, based on the following from their documentation:
> While Svix can handle however many messages you send us, your customers' endpoints may not be able to. This is why the Svix API includes rate-limiting calls to customer endpoints.
> 
> This lets you send as many webhooks per second as you want without having to worry about overloading your customers' systems.

My understanding is that Svix will not respond to our service with rate limiting errors. If my understanding is incorrect, and you would like me to add explicit logic to handle rate limit errors, please let me know. However, I my approach would not be to handle the rate limit errors in the service's code, as it has been implemented to be idempotent, so I would simply make use of [Pub/Sub's exponential backoff retry policy](https://cloud.google.com/pubsub/docs/handling-failures#exponential_backoff).

## Customer Experience Improvements

These are the customer experience improvements I would look to add to the service.

### Svix Consumer App Portal

The first thing I would like to add is to give users access to the [Svix Consumer App Portal](https://docs.svix.com/app-portal), to allow them to manage the endpoint that webhooks are sent to, debug, retry, etc. I don't know enough about the architecture of the Gigs services to really suggest an implementation, but it would be easy to add an endpoint to this service that generates a signed URL that I would imagine could be embedded in the Gigs dashboard.

I believe this would give users the ability to self manage every aspect of their webhooks, and I would only consider adding any other features if they are raised as absolutely required by users. This is a very simple service, and I would be wary of feature creep.

## Running the service in production

These are the improvements that I think the service would need to be production ready

### Authentication

An authentication layer would need to be added to the endpoint to ensure no unauthorized access. As the service would only be used by internal Gigs services, I would also deploy it to a private subnet that is not accessible over the public internet.

### Database

I used SQLite to make this service as easy as possible to setup, seeing as it is only being done for this challenge. For the service to be production ready (with the current codebase), a more suitable RDBMS (such as PostgreSQL) would need to be used.

If I was hosting the service on AWS, I would consider refactoring the service to make use of [DynamoDB](https://aws.amazon.com/dynamodb/) (a NoSQL datastore), as the hosting costs are considerably cheaper than the relational database alternatives, and the data used by this service does not have any complex relationships between entities.

### Error Tracking

I would make use of a third party tool, like [Honeybadger](https://www.honeybadger.io/), to track any errors that occur within the service, and notify the development team. I would consider making use of Honeybadger's [Check-Ins](https://docs.honeybadger.io/guides/check-ins/#setup) functionality, paired with a notification that gets sent on a specific schedule, to ensure that Svix is sending webhooks as expected.

### Monitoring

I would make use of a tool like [Prometheus](https://prometheus.io/) to monitor general service health, and keep track of the number of notifications being created, and the number of failed notifications in the service's database.

### Logging

Currently, the service just uses `puts` to output any logs. To use this service in production, I would implement a more useful [logger](https://sinatrarb.com/contrib/custom_logger), with different log levels, and ensure that the logs are stored in an easily accessible place (I'm not really familiar with Google Cloud, but [Cloud Logging](https://cloud.google.com/logging) seems like a suitable tool).
