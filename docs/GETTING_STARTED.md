# Getting Started

This guide covers local development setup for Smart Hostel.

## Prerequisites

1. Docker and Docker Compose v2
2. Python 3.12+
3. Git

## Environment

Copy the template environment file:

```bash
cp .env.example .env
```

Defaults are already suitable for local Docker usage.

## Local Run

1. Create virtual environment and install dependencies.

```bash
make setup
```

2. Start stack.

```bash
make up
```

3. Confirm services.

```bash
make status
```

## Development Checks

Run lint and tests:

```bash
make ci-check
```

## Useful Commands

1. `make logs` for container logs
2. `make down` to stop stack
3. `make clean` to clear local cache files