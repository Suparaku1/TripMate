# TripMate PostgreSQL Monitoring Script
# Run this script to monitor database and container performance

param(
    [string]$ContainerName = "tripmate_postgres",
    [string]$DbUser = "tripmate_user",
    [string]$DbName = "tripmate_db",
    [int]$RefreshInterval = 5
)

function Show-ContainerStats {
    Write-Host "`n=== Container Stats ===" -ForegroundColor Cyan
    docker stats --no-stream $ContainerName --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
}

function Show-DatabaseSize {
    Write-Host "`n=== Database Size ===" -ForegroundColor Cyan
    docker exec $ContainerName psql -U $DbUser -d $DbName -c "
        SELECT 
            pg_database.datname,
            pg_size_pretty(pg_database_size(pg_database.datname)) AS size
        FROM pg_database
        WHERE datname = '$DbName';
    "
}

function Show-TableSizes {
    Write-Host "`n=== Table Sizes ===" -ForegroundColor Cyan
    docker exec $ContainerName psql -U $DbUser -d $DbName -c "
        SELECT 
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
        FROM pg_tables
        WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
        ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
    "
}

function Show-ActiveConnections {
    Write-Host "`n=== Active Connections ===" -ForegroundColor Cyan
    docker exec $ContainerName psql -U $DbUser -d $DbName -c "
        SELECT 
            datname,
            count(*) as connection_count,
            max(NOW() - pg_stat_activity.query_start) as longest_query
        FROM pg_stat_activity
        WHERE datname IS NOT NULL
        GROUP BY datname;
    "
}

function Show-SlowQueries {
    Write-Host "`n=== Top 10 Slow Queries (if pg_stat_statements enabled) ===" -ForegroundColor Cyan
    docker exec $ContainerName psql -U $DbUser -d $DbName -c "
        SELECT 
            query,
            calls,
            total_time,
            mean_time
        FROM pg_stat_statements
        ORDER BY mean_time DESC
        LIMIT 10;
    " 2>/dev/null || Write-Host "pg_stat_statements extension not enabled"
}

function Show-HealthCheck {
    Write-Host "`n=== Health Check ===" -ForegroundColor Cyan
    docker exec $ContainerName pg_isready -U $DbUser
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Database is accepting connections" -ForegroundColor Green
    } else {
        Write-Host "✗ Database is NOT accepting connections" -ForegroundColor Red
    }
}

# Main monitoring loop
Write-Host "Starting PostgreSQL Monitoring for $ContainerName..." -ForegroundColor Green
Write-Host "Refresh interval: $RefreshInterval seconds. Press Ctrl+C to exit."

while ($true) {
    Clear-Host
    Write-Host "PostgreSQL Monitoring Dashboard" -ForegroundColor Yellow
    Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    
    Show-HealthCheck
    Show-ContainerStats
    Show-DatabaseSize
    Show-TableSizes
    Show-ActiveConnections
    
    Write-Host "`nRefreshing in $RefreshInterval seconds... (Ctrl+C to exit)"
    Start-Sleep -Seconds $RefreshInterval
}
