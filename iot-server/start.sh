#!/bin/bash
echo "Starting iot-server"

GID=1000 UID=1000 docker compose up -d
