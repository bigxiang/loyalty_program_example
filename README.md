# Loyalty Program Example

It's a Rails example for a simple loyalty program, it only implements some backend APIs.

## Development Setup (Docker Compose)

This project is set up for easy local development using Docker Compose.

### Prerequisites
- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/)

### 1. Build and Start the Environment

```
docker compose up --build
```
- This will build the images and start both the `db` (PostgreSQL) and `web` (Rails) services.
- The Rails server will be available at [http://localhost:3000](http://localhost:3000).

### 2. Set Up the Database

In a new terminal, run:

```
docker compose run web bin/rails db:create db:migrate
```
- This will create and migrate all databases as defined in `config/database.yml`.

### 3. Seed the Development Database

To load development seed data (including a sample client and API key):

```
docker compose run web bin/rails db:seed
```
- This will run both `db/seeds.rb` and `db/seeds/development.rb` (see the codebase for details).
- The output will display a sample API key you can use for testing. You need to save the API key
somewhere because it's only displayed once.

### 4. Rails Console (Optional)

To open a Rails console in the running container:

```
docker compose exec web bin/rails console
```

### 5. Running Tests (Optional)

If you have tests set up (e.g., with RSpec):

```
RAILS_ENV=test docker compose run --rm web bundle exec rspec
```

## Using the API

### Example: Earning Points

You can use the `/api/v1/points/earn` endpoint to simulate a user earning points. You will need the API key from the seed output.

#### Example cURL Request

```
curl -X POST http://localhost:3000/api/v1/points/earn \
  -H "Authorization: Bearer <API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"user_identifier": "user123", "birthday": "2000-1-1", "transaction_identifier": "txn123", "is_foreign": true, "amount_in_cents": 12000}'
```
- Replace `<API_KEY>` with the value printed after seeding.
- Adjust the parameters as needed.

#### Expected Response

```
{
    "message": "Points earned successfully",
    "data":{ 
        "transaction_identifier": "txn123",
        "user_identifier": "user123",
        "points_earned": 10,
        "current_points": 10,
        "monthly_points":10
    }
}
```

## Production

This setup is optimized for development. For production builds, see the Dockerfile comments and consider using [Kamal](https://kamal-deploy.org) or your preferred deployment method.