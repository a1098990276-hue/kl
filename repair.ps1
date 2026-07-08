# repair.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "1/9 - إيقاف عمليات node و electron و npm (إن وُجدت)..."
Get-Process -Name electron,node,npm -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "2/9 - أخذ ملكية مجلد node_modules ومنح صلاحيات كاملة..."
if (Test-Path .\node_modules) {
    takeown /F "$PWD\node_modules" /R /D Y | Out-Null
    icacls "$PWD\node_modules" /grant "$env:USERNAME":F /T /C | Out-Null
}

Write-Host "3/9 - حذف node_modules بالقوة..."
cmd /c rmdir /s /q "$PWD\node_modules" 2>$null

Write-Host "4/9 - حذف package-lock.json إن وجد..."
Remove-Item -Force -ErrorAction SilentlyContinue .\package-lock.json

Write-Host "5/9 - تثبيت الحزم من package.json..."
npm install

Write-Host "6/9 - تثبيت إصدار Electron متوافق (32.0.0)..."
npm install electron@32.0.0 --save-dev

Write-Host "7/9 - إعادة بناء better-sqlite3 خصيصاً لـ Electron 32..."
npm rebuild better-sqlite3 --runtime=electron --target=32.0.0 --disturl=https://electronjs.org/headers --build-from-source --force

Write-Host "8/9 - إنشاء ملف إصلاح الجداول fix_defaults.js..."
$js = @'
const Database = require("better-sqlite3");
const db = new Database("khaled.db");

const tables = db.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';").all();

for (const t of tables) {
  const name = t.name;
  const safeName = name.replace(/'/g,"''");
  const cols = db.prepare("PRAGMA table_info('" + safeName + "');").all();

  db.prepare('ALTER TABLE "' + name + '" RENAME TO "' + name + '_old";').run();

  const colDefs = cols.map(c => {
    const colName = c.name;
    const colType = c.type && c.type.trim() ? c.type : 'TEXT';
    let def = c.dflt_value;
    if (def && /datetime|strftime|\(|now\(|CURRENT_TIMESTAMP/i.test(def)) {
      def = 'CURRENT_TIMESTAMP';
    }
    const notnull = c.notnull ? ' NOT NULL' : '';
    const pk = c.pk ? ' PRIMARY KEY' : '';
    return '"' + colName + '" ' + colType + notnull + (def ? ' DEFAULT ' + def : '') + pk;
  }).join(', ');

  const createSQL = 'CREATE TABLE "' + name + '" (' + colDefs + ');';
  db.exec(createSQL);

  const colList = cols.map(c => '"' + c.name + '"').join(', ');
  db.exec('INSERT INTO "' + name + '" (' + colList + ') SELECT ' + colList + ' FROM "' + name + '_old";');

  db.exec('DROP TABLE "' + name + '_old";');
}

console.log('✔ تم إصلاح جميع الجداول بنجاح');
'@

$js | Out-File -FilePath .\fix_defaults.js -Encoding utf8 -Force

Write-Host "9/9 - تشغيل ملف الإصلاح عبر Electron ثم تشغيل التطبيق (إذا نجح)..."
Write-Host "أولاً: تشغيل fix_defaults.js عبر Electron"
electron .\fix_defaults.js

Write-Host "إذا نجح الإصلاح، سيتم تشغيل التطبيق الآن:"
npm start
