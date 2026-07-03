FROM apache/airflow:3.1.0

# 1. Install system dependencies as root
USER root
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# 2. Switch to 'airflow' user to install python packages (This passes the security check)
USER airflow
COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir --user -r /requirements.txt

# 3. Switch back to root so your Compose file 'user: 0:0' override works later
USER root