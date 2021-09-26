#Run Prometheus
docker run -d -h status.cryptofarmers.io -v prometheus:/prometheus -v /data/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml \
  -p 9090:9090 --name prometheus --restart on-failure:3 --security-opt="no-new-privileges=true" \
  --health-cmd='wget -qO- localhost:9090/status || exit 1' --health-start-period=3m \
  prom/prometheus:v2.30.0 \
  --config.file=/etc/prometheus/prometheus.yml \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.console.templates=/etc/prometheus/consoles \
  --web.external-url=http://status.cryptofarmers.io:9090

#Run Grafana
docker run -d -h status.cryptofarmers.io \
  -v /data/monitoring/grafana/db:/var/lib/grafana -v /data/monitoring/grafana/grafana_admin_password:/run/secrets/grafana_admin_password \
  -p 80:3000 --name grafana --restart on-failure:3 --security-opt="no-new-privileges=true" \
  -e GF_SERVER_DOMAIN=cryptofarmers.io \
  -e GF_SERVER_ROOT_URL=http://status.cryptofarmers.io \
  -e GF_SECURITY_ADMIN_PASSWORD__FILE=/run/secrets/grafana_admin_password \
  -e GF_USERS_ALLOW_ORG_CREATE=false \
  -e GF_SESSION_COOKIE_SECURE=true \
  --health-cmd='curl -f localhost:3000/metrics || exit 1' \
  grafana/grafana:8.1.5
