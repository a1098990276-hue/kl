Write-Host "--- Œ«·œ ··„Õ«”»… (≈’œ«— «·„ƒ””… «·„ ﬂ«„·) ---" -ForegroundColor Cyan
Write-Host "1. »‰«¡ «·‰Ÿ«„ | 2. ≈œ«—… «·‘—ﬂ«¡ | 3. ≈œ«—… «·„Œ“Ê‰ | 4. √Ê«„— «·»Ì⁄ | 5. «·—Ê« » | 6.  ﬁ«—Ì— ‘«„·…"
$choice = Read-Host "«Œ — «·⁄„·Ì…"

switch ($choice) {
    "1" { psql -U postgres -f ".\System_Schema.sql"; Write-Host "[?]  „ »‰«¡ «·ÂÌﬂ· »«·ﬂ«„·" -ForegroundColor Green }
    
    "2" { 
        $name = Read-Host "«”„ «·‘—Ìﬂ"
        $type = Read-Host "«·‰Ê⁄ (customer/supplier)"
        psql -U postgres -c "INSERT INTO partners (name, type) VALUES ('$name', '$type');"
    }

    "3" {
        $name = Read-Host "«”„ «·’‰›"
        $qty = Read-Host "«·ﬂ„Ì…"
        $price = Read-Host "«·”⁄—"
        psql -U postgres -c "INSERT INTO products (name, stock, price) VALUES ('$name', $qty, $price);"
    }

    "4" {
        $pid = Read-Host "ID «·‘—Ìﬂ"
        $total = Read-Host "≈Ã„«·Ì «·√„—"
        psql -U postgres -c "INSERT INTO sales_orders (partner_id, total, status) VALUES ($pid, $total, 'completed');"
        Write-Host "[?]  „ ≈‰‘«¡ √„— «·»Ì⁄" -ForegroundColor Green
    }

    "5" {
        $name = Read-Host "«”„ «·„ÊŸ›"
        $salary = Read-Host "«·—« »"
        psql -U postgres -c "INSERT INTO payroll (employee_name, salary, month) VALUES ('$name', $salary, CURRENT_DATE);"
    }

    "6" {
        $type = Read-Host "‰Ê⁄ «· ﬁ—Ì—: [1] „»Ì⁄«  [2] „Œ“Ê‰ [3] —Ê« »"
        if ($type -eq "1") { psql -U postgres -c "SELECT * FROM sales_orders;" }
        if ($type -eq "2") { psql -U postgres -c "SELECT * FROM products;" }
        if ($type -eq "3") { psql -U postgres -c "SELECT * FROM payroll;" }
    }
}