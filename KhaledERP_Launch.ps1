Write-Host "--- جاري فحص بيئة نظام خالد للمحاسبة ---" -ForegroundColor Cyan

$dbStatus = psql -U postgres -c "\dt" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] قاعدة البيانات متصلة." -ForegroundColor Green
} else {
    Write-Host "[ERROR] تعذر الاتصال بقاعدة البيانات." -ForegroundColor Red
    exit
}

$backupPath = "C:\KhaledERP_Backups"
if (!(Test-Path $backupPath)) {
    New-Item -Path $backupPath -ItemType Directory | Out-Null
    Write-Host "[INFO] تم إنشاء مجلد النسخ الاحتياطي." -ForegroundColor Yellow
}

$tableCheck = psql -U postgres -c "\d invoices" 2>$null
if ($tableCheck -match "zatca_qr_base64") {
    Write-Host "[OK] حالة الامتثال الضريبي: جاهز." -ForegroundColor Green
} else {
    Write-Host "[WARN] لم يتم تحديث جداول الفوترة." -ForegroundColor Yellow
}

Write-Host "--- النظام جاهز للعمل - خالد للمحاسبة 2026 ---" -ForegroundColor Green
Read-Host "اضغط Enter لفتح النظام..."
