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

### 3. Rails Console (Optional)

To open a Rails console in the running container:

```
docker compose exec web bin/rails console
```

### 4. Running Tests (Optional)

If you have tests set up (e.g., with RSpec):

```
RAILS_ENV=test docker compose run --rm web bundle exec rspec
```

## Production

This setup is optimized for development. For production builds, see the Dockerfile comments and consider using [Kamal](https://kamal-deploy.org) or your preferred deployment method.