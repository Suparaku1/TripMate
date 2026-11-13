# TripMate PostgreSQL Backup Script
# Run this script to create regular backups of your database

param(
    [string]$BackupDir = "./backups",
    [string]$ContainerName = "tripmate_postgres",
    [string]$DbUser = "tripmate_user",
    [string]$DbName = "tripmate_db"
)

# Create backup directory if it doesn't exist
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
    Write-Host "Created backup directory: $BackupDir"
}

# Generate timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "$BackupDir\tripmate_db_backup_$timestamp.sql"

# Run pg_dump inside the container
Write-Host "Starting database backup..."
docker exec $ContainerName pg_dump -U $DbUser $DbName | Out-File -FilePath $backupFile -Encoding UTF8

if ($LASTEXITCODE -eq 0) {
    $fileSize = (Get-Item $backupFile).Length / 1MB
    $sizeMB = [math]::Round($fileSize, 2)
    Write-Host "Backup completed successfully: $backupFile ($sizeMB MB)"
} else {
    Write-Host "Backup failed with exit code: $LASTEXITCODE"
    Remove-Item $backupFile -ErrorAction SilentlyContinue
    exit 1
}

# Keep only the last 7 backups
$backups = Get-ChildItem $BackupDir -Filter "tripmate_db_backup_*.sql" | Sort-Object LastWriteTime -Descending
if ($backups.Count -gt 7) {
    Write-Host "Cleaning up old backups (keeping last 7)..."
    $backups | Select-Object -Skip 7 | Remove-Item -Verbose
}

Write-Host "Backup script completed."
