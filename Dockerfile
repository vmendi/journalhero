# Build stage for Tailwind CSS
FROM node:20-slim AS tailwind-builder

WORKDIR /app

# Copy all application files (needed for Tailwind to scan templates)
COPY . .

# Install npm dependencies and build Tailwind
WORKDIR /app/tailwindtheme_app/static_src
RUN npm ci && npm run build

# Production stage
FROM python:3.11-slim

WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Copy built Tailwind CSS from builder stage
COPY --from=tailwind-builder /app/tailwindtheme_app/static/css/dist/ ./tailwindtheme_app/static/css/dist/

# Collect static files
RUN python manage.py collectstatic --noinput

# Expose port
EXPOSE 8080

# Run with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "journalhero_site.wsgi:application"]
