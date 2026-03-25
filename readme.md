# Containerized Deployment Project

A production-style containerized web infrastructure featuring load balancing, high availability, and full-stack monitoring — all orchestrated with Docker Compose.

## Architecture Overview

```
                        ┌─────────────────────┐
                        │  HAProxy (Port 80)  │
                        │  Load Balancer      │
                        └────────┬────────────┘
                                 │ Round-robin
              ┌──────────┬───────┴───────┬──────────┐
              ▼          ▼               ▼           ▼
          [website1] [website2]     [website3]  [website4]
          Nginx       Nginx          Nginx        Nginx

       ┌────────────────────────────────────────────────┐
       │  Keepalived (Master + Backup)                  │
       │  Virtual IP: 192.168.100.100  HA Failover      │
       └────────────────────────────────────────────────┘

       ┌────────────────────────────────────────────────┐
       │  Prometheus (Port 9090)  →  Grafana (Port 3000)│
       │  Scrapes HAProxy metrics every 15s             │
       └────────────────────────────────────────────────┘
```

## Stack

| Component    | Image / Version         | Purpose                            |
|--------------|-------------------------|------------------------------------|
| HAProxy      | `haproxy:2.9-alpine`    | Load balancer & stats endpoint     |
| Nginx        | `nginx:1.25-alpine`     | Static site servers (×4)           |
| Keepalived   | `osixia/keepalived:2.0.20` | High availability / VIP failover |
| Prometheus   | `prom/prometheus:v2.51.0` | Metrics collection               |
| Grafana      | `grafana/grafana:10.4.0` | Metrics visualization             |

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) v24+
- [Docker Compose](https://docs.docker.com/compose/) v2+

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/your-username/containerized-deployment-project.git
cd containerized-deployment-project
```

### 2. Start all services

```bash
docker compose up -d --build
```

### 3. Verify all containers are running

```bash
docker compose ps
```

## Accessing the Services

| Service             | URL                          | Description                        |
|---------------------|------------------------------|------------------------------------|
| Website             | http://localhost             | Load-balanced static sites         |
| HAProxy Stats       | http://localhost:8404/stats  | HAProxy statistics dashboard       |
| HAProxy Metrics     | http://localhost:8404/metrics| Prometheus-compatible metrics      |
| Prometheus          | http://localhost:9090        | Metrics & query interface          |
| Grafana             | http://localhost:3000        | Monitoring dashboards              |

> **Grafana default credentials:** `admin` / `admin`

## Load Balancer Behavior

HAProxy distributes traffic across all four backends using **round-robin** by default. It also supports hostname-based routing — requests to `site1.local`, `site2.local`, `site3.local`, or `site4.local` are routed to their respective backends.

Health checks run every 5 seconds; a backend is marked down after 3 consecutive failures and restored after 2 successes.

## High Availability

Keepalived manages a Virtual IP (`192.168.100.100`) shared between a **master** and **backup** node. If the master fails (e.g., HAProxy goes down), the backup automatically takes over the VIP within seconds.

| Node   | Priority |
|--------|----------|
| Master | 100      |
| Backup | 90       |

## Monitoring

Prometheus scrapes HAProxy metrics every **15 seconds** and retains data for **15 days**.

A pre-built HAProxy dashboard is automatically provisioned in Grafana via the `grafana/provisioning/` directory. No manual setup is required after `docker compose up`.

## Simulating Load (Testing)

Send 100 requests to observe round-robin balancing in the HAProxy stats page:

```bash
for i in $(seq 1 100); do curl -s http://localhost/ > /dev/null; done
```

## Project Structure

```
containerized-deployment-project/
├── docker-compose.yml
├── haproxy/
│   └── haproxy.cfg
├── keepalived/
│   ├── Dockerfile
│   ├── keepalived-master.conf
│   ├── keepalived-backup.conf
│   └── entrypoint.sh
├── prometheus/
│   └── prometheus.yml
├── grafana/
│   ├── dashboards/
│   └── provisioning/
│       ├── datasources/
│       └── dashboards/
└── websites/
    ├── site1/
    ├── site2/
    ├── site3/
    └── site4/
```

## Stopping the Stack

```bash
docker compose down
```

To also remove persistent volumes (Prometheus & Grafana data):

```bash
docker compose down -v
```
