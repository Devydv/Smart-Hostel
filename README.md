# Smart Hostel

Smart Hostel is a role-based hostel management system built with Flask and MySQL. It supports student services, warden workflows, and admin operations from separate dashboards.

## Features

1. Authentication and registration for Student, Warden, and Admin roles.
2. Student portal:
	- Dashboard with room, fee, and complaint summary.
	- Room booking requests.
	- Complaint submission and tracking.
	- Attendance view.
	- Food order requests.
	- Fee history.
	- Announcements feed.
3. Warden portal:
	- Dashboard with occupancy and complaint stats.
	- Approve or reject room allocation requests.
	- Resolve or escalate complaints.
	- Create and delete announcements.
4. Admin portal:
	- System dashboard and summary metrics.
	- Manage rooms and students.
	- Handle complaint lifecycle.
	- View reports for occupancy, fees, and pending issues.
5. Operational endpoints:
	- Health check endpoint.
	- Prometheus metrics endpoint.
6. Audit logging:
	- Tracks login/logout and write actions for admin, warden, and student roles.

## Tech Stack

1. Backend: Flask
2. Database: MySQL 8
3. App server (container): Gunicorn
4. Monitoring: Prometheus + Grafana + mysqld-exporter
5. Dev quality tools: Ruff, Pytest
6. Container orchestration (local): Docker Compose

## Project Structure

1. `app.py`: Flask routes and role-based business logic.
2. `db.py`: MySQL connection pooling.
3. `templates/`: Role-specific UI pages.
4. `infra/sql/init.sql`: Full schema + demo seed data.
5. `docker-compose.yml`: App, DB, and monitoring services.
6. `Makefile`: Common developer and CI helper commands.

## Database Tables

The schema is initialized from `infra/sql/init.sql` and includes:

1. `students`
2. `wardens`
3. `admins`
4. `users`
5. `rooms`
6. `room_allocation`
7. `complaints`
8. `fees`
9. `attendance`
10. `food_orders`
11. `announcements`

## Demo Accounts

Seeded by `infra/sql/init.sql`:

1. Student: `student@smarthostel.com` / `123456`
2. Warden: `warden@smarthostel.com` / `123456`
3. Admin: `admin@smarthostel.com` / `123456`

Note: On first successful login, legacy plaintext passwords can be migrated to hashed values automatically.

## Quick Start (Docker)

1. Build and start all services:

```bash
make up
```

2. Check status:

```bash
make status
```

3. Stop services:

```bash
make down
```

## Local URLs

1. App: http://localhost:5000
2. Health: http://localhost:5000/health
3. Metrics: http://localhost:5000/metrics
4. Prometheus: http://localhost:9090
5. Grafana: http://localhost:3000

If port 5000 is occupied:

```bash
WEB_PORT=5002 make up
```

## Run Without Docker (App Only)

1. Create virtual environment and install dependencies:

```bash
make setup
```

2. Ensure MySQL is running and schema is loaded from `infra/sql/init.sql`.

3. Export DB variables (example):

```bash
export DB_HOST=localhost
export DB_USER=hostel
export DB_PASSWORD=hostel_pass
export DB_NAME=hostel_management
```

4. Start Flask app:

```bash
python app.py
```

## Important Routes

1. Public:
	- `/`
	- `/register`
	- `/logout`
	- `/health`
	- `/metrics`
2. Student:
	- `/student/dashboard`
	- `/student/room-booking`
	- `/student/complaints`
	- `/student/attendance`
	- `/student/food-order`
	- `/student/fees`
	- `/student/announcements`
3. Warden:
	- `/warden/dashboard`
	- `/warden/complaints`
	- `/warden/room-approval`
	- `/warden/announcements`
4. Admin:
	- `/admin/dashboard`
	- `/admin/complaints`
	- `/admin/rooms`
	- `/admin/students`
	- `/admin/reports`

## Developer Commands

1. `make setup`: Create `.venv` and install dependencies.
2. `make up`: Start local container stack.
3. `make down`: Stop local container stack.
4. `make lint`: Run Ruff checks.
5. `make test`: Run Pytest.
6. `make coverage`: Run Pytest with coverage report.
7. `make ci-check`: Lint + test + parity + compose config + docker build.
8. `make logs`: Tail service logs.

## CI/CD

1. CI runs on pushes and pull requests: lint, tests, environment parity, and Docker build checks.
2. CD deploys to EC2 on push to `main` using Ansible.
3. Deployment pipeline verifies app and monitoring health checks.

Required GitHub repository secrets:

1. `EC2_HOST`
2. `EC2_USER`
3. `EC2_SSH_PRIVATE_KEY`

## Additional Documentation

1. `docs/PROJECT.md`
2. `docs/TOOLS.md`
3. `docs/GETTING_STARTED.md`
4. `docs/DEPLOYMENT.md`
5. `docs/DEMO_SCRIPT.md`
6. `infra/terraform/bootstrap/README.md`
