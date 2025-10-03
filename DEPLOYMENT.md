# Deployment Guide for Journal Hero on Flightcontrol

## Overview
Your app is now configured to deploy to AWS ECS via Flightcontrol. The configuration includes:
- **Web Service**: Fargate container running Django with Gunicorn
- **Database**: SQLite (note: not recommended for production with multiple instances)
- **Static Files**: Served via WhiteNoise

⚠️ **Important**: SQLite is being used with a single Fargate instance. If you scale to multiple instances, each will have its own database file, which will cause data inconsistency. For production at scale, consider PostgreSQL.

## Next Steps in Flightcontrol Dashboard

### 1. Set Environment Variables
Go to your environment in the Flightcontrol dashboard and add these environment variables:

#### Required Variables:
- `SECRET_KEY`: Generate a new Django secret key for production
  - Run: `python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'`
  - Use the output as your SECRET_KEY
- `ALLOWED_HOSTS`: Your production domain(s), comma-separated
  - Example: `journalhero.com,www.journalhero.com`
  - Start with your Flightcontrol URL first, then add your custom domain later
- `DEBUG`: Set to `False` for production


### 2. Commit and Push
```bash
git add .
git commit -m "Configure Flightcontrol deployment"
git push origin main
```

### 3. Deployment Process
Once you push to `main`, Flightcontrol will automatically:
1. ✅ Build your Docker container with Nixpacks
2. ✅ Install Python dependencies
3. ✅ Build Tailwind CSS (`python manage.py tailwind build`)
4. ✅ Collect static files (`python manage.py collectstatic`)
5. ✅ Run migrations on SQLite (`python manage.py migrate`)
6. ✅ Start Gunicorn web server (single worker for SQLite)
7. ✅ Deploy to ECS Fargate

### 4. Monitoring
- Watch the build logs in the Flightcontrol dashboard
- Once deployed, you'll get a URL like: `https://journalhero-web.flightcontrol.app`

## What Changed

### Configuration Files
- **flightcontrol.json**: Added web service definition (using SQLite, single instance)
- **requirements.txt**: Added production dependencies:
  - `gunicorn`: Production WSGI server
  - `whitenoise`: Static file serving

### Django Settings
- **settings.py**: Now production-ready with:
  - Environment variable support
  - SQLite database (same as local dev)
  - WhiteNoise for static file serving
  - Security settings (HTTPS redirect, secure cookies, HSTS)

## Local Development
Your local development setup is unchanged:
- Still uses SQLite
- Still uses `runserver`
- Still uses `tailwind start` for CSS development

## Cost Estimate (AWS)
- Fargate (0.25 vCPU, 0.5GB, single instance): ~$10/month
- Total: ~$10/month (no separate database costs)

## Troubleshooting

### Build fails on "tailwind build"
- Ensure Node.js is installed in the build environment
- Nixpacks should auto-detect and install Node.js

### Database persistence
- SQLite data will persist within the container's filesystem
- If the container restarts, the database will be reset unless using EFS or persistent volumes
- Consider adding an EFS volume if you need persistent SQLite data

### Static files not loading
- Verify `python manage.py collectstatic` ran successfully
- Check WhiteNoise is in MIDDLEWARE

### Health check failing
- Check that your app responds to `/` (home page)
- Verify port 8080 is correct in flightcontrol.json

