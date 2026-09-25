#!/bin/bash
# Yojna Setu V2 Production Startup Script
# Environment variables must be loaded from systemd, vault, or .env
set -e

if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

echo "Starting Yojna Setu V2 application..."
exec java -Xmx512m -XX:+UseG1GC -jar target/yojna-setu-0.0.1-SNAPSHOT.jar
