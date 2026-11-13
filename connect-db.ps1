# TripMate PostgreSQL Connection Helper
# Use this script to connect to the database

param(
    [string]$Mode = "shell",  # "shell", "backup", "restore", "query"
    [string]$SqlFile = ""
)

$ContainerName = "tripmate_postgres"
$DbUser = "tripmate_user"
$DbName = "tripmate_db"
$DbPassword = "0iDk5#RCDHjEnLK&tIPmKijP"

# Set environment variable for password (optional, for psql)
$env:PGPASSWORD = $DbPassword

switch ($Mode) {
    "shell" {
        Write-Host "Connecting to PostgreSQL shell..."
        Write-Host "Connection details:"
        Write-Host "  Host: localhost"
        Write-Host "  Port: 5432"
        Write-Host "  User: $DbUser"
        Write-Host "  Database: $DbName"
        Write-Host ""
        Write-Host "To exit, type: \q"
        docker exec -it $ContainerName psql -h localhost -U $DbUser -d $DbName
    }
    "backup" {
        Write-Host "Running backup..."
        & ".\backup-db.ps1"
    }
    "restore" {
        if (-not $SqlFile) {
            Write-Host "Error: SqlFile parameter required for restore mode"
            exit 1
        }
        Write-Host "Restoring from: $SqlFile"
        Get-Content $SqlFile | docker exec -i $ContainerName psql -U $DbUser -d $DbName
    }
    "query" {
        if (-not $SqlFile) {
            Write-Host "Error: SqlFile parameter required for query mode"
            exit 1
        }
        Write-Host "Executing query from: $SqlFile"
        Get-Content $SqlFile | docker exec -i $ContainerName psql -U $DbUser -d $DbName
    }
    default {
        Write-Host "Usage: .\connect-db.ps1 -Mode <mode> [-SqlFile <file>]"
        Write-Host ""
        Write-Host "Modes:"
        Write-Host "  shell    - Interactive psql shell (default)"
        Write-Host "  backup   - Create database backup"
        Write-Host "  restore  - Restore from SQL file (requires -SqlFile)"
        Write-Host "  query    - Execute query from SQL file (requires -SqlFile)"
        Write-Host ""
        Write-Host "Examples:"
        Write-Host "  .\connect-db.ps1"
        Write-Host "  .\connect-db.ps1 -Mode backup"
        Write-Host "  .\connect-db.ps1 -Mode restore -SqlFile .\backups\tripmate_db_backup_20260721_100000.sql"
    }
}
