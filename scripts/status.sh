#!/bin/bash

# Horilla Status Check Script
echo "======================================="
echo "   HORILLA HRMS - STATUS CHECK"
echo "======================================="
echo ""

# Check containers
echo "📦 CONTAINERS STATUS:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep horilla
echo ""

# Check database connection
echo "🗄️ DATABASE STATUS:"
docker exec postgres-horilla-vainilla pg_isready -U horilla && echo "✅ Database is ready" || echo "❌ Database is not ready"
echo ""

# Check web service
echo "🌐 WEB SERVICE STATUS:"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8010 | grep -q "301\|302\|200"; then
    echo "✅ Web service is responding"
else
    echo "❌ Web service is not responding"
fi
echo ""

# Check disk usage
echo "💾 DISK USAGE:"
echo "App directory: $(du -sh /nvme0n1-disk/clientes/vainilla/horilla/ 2>/dev/null | cut -f1)"
echo "Database: $(du -sh /nvme1n1-disk/databases/vainilla/postgres-horilla/ 2>/dev/null | cut -f1)"
echo ""

# Show access info
echo "🔗 ACCESS INFORMATION:"
echo "Local URL: http://localhost:8010"
echo "Public URL: https://rh.vainillacr.com (pending Nginx config)"
echo "DB Init Password: Check .env file"
echo ""

# Show recent logs
echo "📝 RECENT LOGS (last 5 lines):"
docker logs horilla-vainilla 2>&1 | tail -5
echo ""
echo "======================================="
