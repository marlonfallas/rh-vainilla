FROM python:3.10-slim-bullseye

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcairo2-dev \
    gcc \
    postgresql-client \
    gettext \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app/

# Copy requirements first for better caching
COPY horilla_data/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY horilla_data/ .

# Copy and prepare entrypoint
RUN chmod +x /app/entrypoint.sh

# Create media directory
RUN mkdir -p /app/media

# Compile messages for translations
RUN python manage.py compilemessages || true

EXPOSE 8000

CMD ["sh", "./entrypoint.sh"]
