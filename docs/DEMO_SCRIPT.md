# Demo Script (Professor Walkthrough)

## 1) Start the stack

```bash
WEB_PORT=5002 make up
```

## 2) Show the app

- App: http://localhost:5002
- Health: http://localhost:5002/health
- Metrics: http://localhost:5002/metrics

Demo logins:

- Student: student@smarthostel.com / 123456
- Warden: warden@smarthostel.com / 123456
- Admin: admin@smarthostel.com / 123456

## 3) Show monitoring

Prometheus:

- UI: http://localhost:9090
- Targets: http://localhost:9090/targets
- Query: `up`

Grafana:

- UI: http://localhost:3000
- Dashboard: http://localhost:3000/d/smart-hostel-overview/smart-hostel-overview
- Import Node Exporter Full dashboard (ID: 1860)

## 4) Show DevOps pipeline

- Open GitHub Actions -> CI-CD workflow
- Show lint/test/build steps
- Show EC2 deploy stage

## 5) Show alerts

- Prometheus Alerts: http://localhost:9090/alerts

## 6) Optional: backup demo

```bash
make backup
```

## 7) Stop the stack

```bash
make down
```
