#!/bin/sh
set -e

# Start OrangeSlice Node.js sidecar in the background (port 8002)
PORT=8002 node orangeslice/server.js &
OS_PID=$!

# Wait for the sidecar to be ready
echo "Waiting for OrangeSlice sidecar..."
for i in $(seq 1 30); do
    if curl -sf http://localhost:8002/health > /dev/null 2>&1; then
        echo "OrangeSlice sidecar ready."
        break
    fi
    sleep 1
done

# Start the main Amplemarket MCP server (port 8000, foreground)
exec python -m uvicorn server:app --host 0.0.0.0 --port 8000
