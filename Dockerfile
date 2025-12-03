## Parent image
FROM python:3.12-slim

## Essential environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

## Work directory inside the docker container
WORKDIR /app

## Installing system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps first (export from Poetry!)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy rest of the app
COPY . .

# Make sure /app is on PYTHONPATH
ENV PYTHONPATH=/app

## Expose only flask port
EXPOSE 5000

## Run the Flask app the same way as local
CMD ["python", "-m", "app.application"]
