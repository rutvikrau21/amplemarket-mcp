FROM python:3.12-slim

# Install Node.js (LTS) alongside Python
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python deps (Amplemarket MCP)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip -r requirements.txt

# Install Node.js deps (OrangeSlice sidecar)
COPY orangeslice/package.json orangeslice/package-lock.json ./orangeslice/
RUN cd orangeslice && npm ci --omit=dev

# Copy application code
COPY server.py .
COPY orangeslice/server.js ./orangeslice/

# Startup script: launch OrangeSlice sidecar then the main MCP server
COPY start.sh .
RUN chmod +x start.sh

EXPOSE 8000
CMD ["./start.sh"]
