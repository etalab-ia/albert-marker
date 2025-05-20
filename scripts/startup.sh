#!/bin/bash
set -e

# Environment variables
WORKERS=${WORKERS:-1}
WORKER_CONNECTIONS=${WORKER_CONNECTIONS:-1000}
TIMEOUT=${TIMEOUT:-30}
KEEP_ALIVE=${KEEP_ALIVE:-75}
GRACEFUL_TIMEOUT=${GRACEFUL_TIMEOUT:-75}
GUNICORN_CMD_ARGS=${GUNICORN_CMD_ARGS:-""}
HOST=${HOST:-0.0.0.0}
PORT=${PORT:-8000}
LOG_LEVEL=${LOG_LEVEL:-info}

echo "Starting marker-server on ${HOST}:${PORT} with ${WORKERS} workers"

# Start the application server
exec gunicorn server.main:app \
    --workers $WORKERS \
    --worker-connections $WORKER_CONNECTIONS \
    --timeout $TIMEOUT \
    --worker-class uvicorn.workers.UvicornWorker \
    --keep-alive $KEEP_ALIVE \
    --graceful-timeout $GRACEFUL_TIMEOUT \
    --bind ${HOST}:${PORT} \
    --log-level $LOG_LEVEL \
    $GUNICORN_CMD_ARGS
