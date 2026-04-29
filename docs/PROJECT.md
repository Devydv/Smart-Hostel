# Project Overview

Smart Hostel is a role-based hostel management system built with Flask and MySQL. It provides separate dashboards for students, wardens, and admins, with core workflows such as room allocation, complaints, attendance, and fees.

## Core Features

1. Authentication and registration for Student, Warden, and Admin roles.
2. Student portal:
   - Room booking requests and approvals.
   - Complaint creation and tracking.
   - Attendance view.
   - Food order requests.
   - Fee history.
   - Announcements.
3. Warden portal:
   - Approve or reject room allocation requests.
   - Manage complaints and announcements.
4. Admin portal:
   - Manage rooms and students.
   - Review reports and complaint lifecycle.
5. Operational endpoints:
   - Health check endpoint.
   - Prometheus metrics endpoint.
6. Audit logging:
   - Tracks login/logout and write actions.

## Project Structure (high level)

- `app.py` - Flask routes and business logic.
- `db.py` - MySQL connection pooling.
- `templates/` - UI templates.
- `static/` - CSS and static assets.
- `infra/sql/init.sql` - Schema and demo seed data.
- `docker-compose.yml` - App, database, and monitoring services.
