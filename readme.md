cd containerized-deployment
docker compose up -d --build
docker compose ps
http://localhost/          in browser refreshing the website
http://localhost:8404/stat  for Haproxy
http://localhost:9090     Promethesus
http://localhost:3000     Grafana
for i in $(seq 1 100); do curl -s http://localhost/ > /dev/null;   for testing
