#Run Prometheus
docker run -d -h status.cryptofarmers.io -v prometheus:/prometheus -v /data/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml \
  -p 9090:9090 --name prometheus --restart on-failure:3 --security-opt="no-new-privileges=true" \
  --health-cmd='wget -qO- localhost:9090/status || exit 1' --health-start-period=3m \
  prom/prometheus:v2.30.0 \
  --config.file=/etc/prometheus/prometheus.yml \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.console.templates=/etc/prometheus/consoles \
  --web.external-url=http://status.cryptofarmers.io:9090
