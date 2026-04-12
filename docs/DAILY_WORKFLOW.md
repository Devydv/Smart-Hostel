# Daily Workflow

This guide is the default day-to-day path.

## 1. Start and run locally

```bash
make up
```

App URL:
1. http://localhost:5000

## 2. Run checks before commit

```bash
make ci-check
```

This runs:
1. Ruff lint
2. Pytest
3. Docker compose config validation
4. Docker image build

## 3. Commit and push

```bash
git add .
git commit -m "your change"
git push origin <branch>
```

## 4. Watch CI/CD

1. CI runs on push and pull requests.
2. CD runs on pushes to `main`.

## 5. Stop local services

```bash
make down
```
