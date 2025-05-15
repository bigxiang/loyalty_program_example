# Loyalty Program Example

A simple loyalty program that allows users to earn points and get rewards.

## API Endpoints

### Earn Points

```bash
curl -X POST http://localhost:3000/api/v1/points/earn \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{"user_identifier": "user123", "birthday": "2000-1-1", "transaction_identifier": "txn123", "is_foreign": true, "amount_in_cents": 12000}'
```

Response:
```json
{
  "message": "Points earned successfully",
  "data": {
    "transaction_identifier": "txn123",
    "user_identifier": "user123",
    "points_earned": 120,
    "current_points": 120,
    "monthly_points": 120
  }
}
```

### Issue Rewards

```bash
curl -X POST http://localhost:3000/api/v1/rewards/issue \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{"user_identifier": "user123"}'
```

Response:
```json
{
  "message": "Rewards issued successfully",
  "data": {
    "reward_items": [
      {
        "name": "Free Coffee",
        "quantity": 1
      }
    ]
  }
}
```

Error Response (No applicable rewards):
```json
{
  "message": "Error issuing rewards",
  "errors": ["No rewards applicable"]
}
```

Error Response (User not found):
```json
{
  "message": "Error issuing rewards",
  "errors": ["User not found"]
}
```

Error Response (Reward already issued):
```json
{
  "message": "Error issuing rewards",
  "errors": ["This reward has already been issued to this user"]
}
```

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

## Production

This setup is optimized for development. For production builds, see the Dockerfile comments and consider using [Kamal](https://kamal-deploy.org) or your preferred deployment method.