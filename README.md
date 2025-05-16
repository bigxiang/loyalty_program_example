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

## Configuring Rules

The loyalty program uses a flexible rule system to determine when points are earned and rewards are issued. Rules are configured through the database and can be managed via the Rails console or through your application's admin interface.

### Point Earning Rules

Point earning rules determine how users earn points from their transactions. Each rule has a level requirement and specific conditions that must be met.

#### Level 1: Standard Points
```ruby
PointRule.create!(
  name: "Standard Points",
  level: 1,
  active: true,
  conditions: {
    transaction: {
      amount_in_cents: { gte: 10000 } # $100.00
    }
  },
  actions: {
    points: 10,
    per: 10000 # Points per $100
  }
)
```

#### Level 2: Foreign Transaction Multiplier
```ruby
PointRule.create!(
  name: "Foreign Transaction Bonus",
  level: 2,
  active: true,
  conditions: {
    transaction: {
      is_foreign: { eq: true }
    }
  },
  actions: {
    multiplier: 2 # 2x points for foreign transactions
  }
)
```

### Reward Rules

Reward rules determine when users receive rewards. Each rule has a level requirement and specific conditions that must be met.

#### Level 1: Monthly Points Reward
```ruby
RewardRule.create!(
  name: "Monthly Points Reward",
  level: 1,
  active: true,
  conditions: {
    user: {
      monthly_points: { gte: 100 }
    }
  },
  actions: {
    name: "Free Coffee",
    quantity: 1
  },
  repeat_condition: {
    type: "monthly"
  }
)
```

#### Level 2: Birthday Reward
```ruby
RewardRule.create!(
  name: "Birthday Reward",
  level: 2,
  active: true,
  conditions: {
    user: {
      birthday_in_month: { eq: true }
    }
  },
  actions: {
    name: "Free Coffee",
    quantity: 1
  },
  repeat_condition: {
    type: "yearly"
  }
)
```

#### Level 2: New User Spending Reward
```ruby
RewardRule.create!(
  name: "New User Spending Reward",
  level: 2,
  active: true,
  conditions: {
    user: {
      registered_at: { gte: "{current.months_ago(2)}" },
      total_spent_in_cents: { gte: 100000 } # $1000.00
    }
  },
  actions: {
    name: "Free Movie Tickets",
    quantity: 1
  }
)
```

### Rule Configuration Details

- **Level**: Determines when a rule becomes available to users (user's level must be >= rule's level)
- **Conditions**: JSON object defining when the rule applies
  - Supports operators: `gte` (≥), `lte` (≤), `gt` (>), `eq` (=)
  - Can use dynamic values with `{context.method(args)}` syntax
- **Actions**: JSON object defining what happens when conditions are met
  - For points: `points` (amount), `per` (amount per points), `multiplier` (multiplier)
  - For rewards: `name` (reward name), `quantity` (number of rewards)
- **Repeat Condition**: Optional JSON object for reward rules
  - `type`: "monthly" or "yearly" to control how often the reward can be issued

### Available Contexts and Attributes

#### Transaction Context
- `amount_in_cents`: Transaction amount in cents
- `is_foreign`: Whether the transaction is from a foreign country

#### User Context
- `monthly_points`: Points earned in current month
- `total_spent_in_cents`: Total amount spent
- `registered_at`: User registration date
- `birthday_in_month`: Whether it's the user's birthday month

#### Current Context (Time-based)
- `months_ago(n)`: Date n months ago
- `beginning_of_month`: Start of current month
- `end_of_month`: End of current month

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