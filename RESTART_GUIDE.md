# TripMate AI - Complete Restart Guide

## Quick Start (After Laptop Restart)

### Step 1: Open PowerShell
Press `Win + R`, type `powershell`, and press Enter.

### Step 2: Navigate to Project
```powershell
cd "C:\TripMate-AI-A-Multi-Agent-Travel-Planner-with-LangGraph"
```

### Step 3: Start All Containers
```powershell
docker compose up -d
```

### Step 4: Wait for Startup
Wait 15-20 seconds for both containers to start.

### Step 5: Verify Everything is Running
```powershell
docker ps --filter "name=tripmate" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

You should see:
```
NAMES               STATUS                    PORTS
tripmate_app        Up X seconds              0.0.0.0:8000->8000/tcp
tripmate_postgres   Up X seconds (healthy)    0.0.0.0:5432->5432/tcp
```

### Step 6: Open in Browser
Go to: http://localhost:8000

---

## Troubleshooting

### If containers don't start:

**Check if Docker daemon is running:**
```powershell
docker ps
```

If you get an error, start Docker Desktop:
- Click Start menu
- Type "Docker Desktop"
- Click to launch it
- Wait 30 seconds for it to fully start
- Try `docker ps` again

### If port 8000 refuses to connect:

Wait another 15 seconds and refresh the browser. The app takes time to initialize.

If still not working:
```powershell
docker logs tripmate_app --tail 20
```

### If you want to see real-time logs:
```powershell
docker logs tripmate_app -f
```
(Press Ctrl+C to stop)

### If you need to restart just the app (not the database):
```powershell
docker compose restart app
```

### To completely stop everything:
```powershell
docker compose down
```

### To stop but keep data:
```powershell
docker compose stop
```

### To resume after stopping:
```powershell
docker compose start
```

---

## Important Files

- **Project location:** `C:\TripMate-AI-A-Multi-Agent-Travel-Planner-with-LangGraph`
- **Configuration:** `.env` (contains API keys - DO NOT DELETE)
- **Docker config:** `docker-compose.yml`
- **Database backups:** `./backups/` (created by backup script)

---

## Database Connection

If you need to connect directly to PostgreSQL:

```powershell
cd "C:\TripMate-AI-A-Multi-Agent-Travel-Planner-with-LangGraph"
powershell -File .\connect-db.ps1
```

For backups:
```powershell
powershell -File .\backup-db.ps1
```

For monitoring:
```powershell
powershell -File .\monitor-db.ps1
```

---

## One-Line Quick Restart Command

Copy and paste this entire command into PowerShell:

```powershell
cd "C:\TripMate-AI-A-Multi-Agent-Travel-Planner-with-LangGraph"; docker compose up -d; Write-Host "Waiting for startup..."; Start-Sleep -Seconds 15; docker ps --filter "name=tripmate" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"; Write-Host "Open http://localhost:8000 in your browser"
```

This will:
1. Navigate to the project folder
2. Start all containers
3. Wait 15 seconds
4. Show container status
5. Print the URL to open

---

## Scheduled Automated Restart (Optional)

If you want your app to auto-start when Windows boots:

**Create a batch file:**
1. Open Notepad
2. Paste this:
```batch
@echo off
cd C:\TripMate-AI-A-Multi-Agent-Travel-Planner-with-LangGraph
docker compose up -d
timeout /t 15
start http://localhost:8000
```
3. Save as `C:\start-tripmate.bat`
4. Press Win+R, type `shell:startup`, press Enter
5. Right-click in the folder → New → Shortcut
6. Paste: `C:\start-tripmate.bat`
7. Click Create
8. Now your app auto-starts when you boot your laptop

---

## API Keys Reference

Your `.env` file contains:
- GROQ_API_KEY - for AI responses (required)
- AVIATIONSTACK_API_KEY - for flight data (required)
- TAVILY_API_KEY - for hotel searches (required)
- DATABASE_URL - PostgreSQL connection (auto-configured)

If you need to update keys:
1. Open `.env` in Notepad
2. Edit the values
3. Run: `docker compose restart app`
4. Wait 10 seconds and refresh browser

---

## Support Commands Summary

| Task | Command |
|------|---------|
| Start everything | `docker compose up -d` |
| Stop everything | `docker compose down` |
| Restart app only | `docker compose restart app` |
| View app logs | `docker logs tripmate_app -f` |
| View database logs | `docker logs tripmate_postgres -f` |
| Check status | `docker ps --filter "name=tripmate"` |
| Backup database | `.\backup-db.ps1` |
| Monitor database | `.\monitor-db.ps1` |
| Connect to database | `.\connect-db.ps1` |

