
# ==============================================================================
# نظام خالد للمحاسبة - الدفعة الأولى: هيكل المشروع + قاعدة البيانات
# ==============================================================================
$ErrorActionPreference = 'Stop'
$AppDir = "$PSScriptRoot\KhaledERP"
$Dirs = @("$AppDir","$AppDir\src","$AppDir\src\css","$AppDir\src\js")
foreach ($d in $Dirs) { if(-not(Test-Path $d)){ New-Item -Path $d -ItemType Directory -Force | Out-Null } }

# --- package.json ---
@'
{
  "name": "khaled-erp",
  "version": "1.0.0",
  "description": "نظام خالد للمحاسبة",
  "main": "main.js",
  "scripts": {
    "start": "electron .",
    "build": "electron-builder --win --x64"
  },
  "build": {
    "appId": "com.khaled.erp",
    "productName": "خالد للمحاسبة",
    "win": { "target": "nsis" },
    "nsis": {
      "oneClick": false,
      "allowToChangeInstallationDirectory": true,
      "createDesktopShortcut": true,
      "shortcutName": "خالد للمحاسبة"
    },
    "directories": { "output": "dist" }
  },
  "dependencies": { "better-sqlite3": "^9.4.3" },
  "devDependencies": { "electron": "^28.3.3", "electron-builder": "^24.13.3" }
}
'@ | Set-Content "$AppDir\package.json" -Encoding utf8

# --- main.js ---
@'
const { app, BrowserWindow, ipcMain, Menu, dialog } = require("electron");
const path = require("path");
const Database = require("better-sqlite3");

let win, db;

function initDB() {
  const p = path.join(app.getPath("userData"), "khaled_erp.db");
  db = new Database(p);
  db.pragma("journal_mode = WAL");
  db.pragma("foreign_keys = ON");
  db.exec(`
    CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT);
    CREATE TABLE IF NOT EXISTS products (
      id INTEGER PRIMARY KEY AUTOINCREMENT, code TEXT, name TEXT NOT NULL,
      category TEXT, unit TEXT DEFAULT "قطعة",
      cost_price REAL DEFAULT 0, sell_price REAL DEFAULT 0,
      qty REAL DEFAULT 0, min_qty REAL DEFAULT 5,
      barcode TEXT, is_active INTEGER DEFAULT 1,
      created_at TEXT DEFAULT (date("now"))
    );
    CREATE TABLE IF NOT EXISTS customers (
      id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
      phone TEXT, email TEXT, vat_number TEXT, address TEXT,
      credit_limit REAL DEFAULT 0, balance REAL DEFAULT 0,
      is_active INTEGER DEFAULT 1, created_at TEXT DEFAULT (date("now"))
    );
    CREATE TABLE IF NOT EXISTS suppliers (
      id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
      phone TEXT, email TEXT, vat_number TEXT, address TEXT,
      balance REAL DEFAULT 0, is_active INTEGER DEFAULT 1,
      created_at TEXT DEFAULT (date("now"))
    );
    CREATE TABLE IF NOT EXISTS invoices (
      id INTEGER PRIMARY KEY AUTOINCREMENT, invoice_number TEXT UNIQUE,
      customer_id INTEGER, date TEXT NOT NULL,
      subtotal REAL DEFAULT 0, discount REAL DEFAULT 0,
      tax_amount REAL DEFAULT 0, total REAL DEFAULT 0,
      payment_method TEXT DEFAULT "نقدي", status TEXT DEFAULT "مدفوعة",
      notes TEXT, created_at TEXT DEFAULT (datetime("now"))
    );
    CREATE TABLE IF NOT EXISTS invoice_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT, invoice_id INTEGER,
      product_id INTEGER, product_name TEXT, qty REAL,
      unit_price REAL, discount REAL DEFAULT 0, line_total REAL
    );
    CREATE TABLE IF NOT EXISTS purchases (
      id INTEGER PRIMARY KEY AUTOINCREMENT, purchase_number TEXT UNIQUE,
      supplier_id INTEGER, date TEXT NOT NULL,
      subtotal REAL DEFAULT 0, tax_amount REAL DEFAULT 0,
      total REAL DEFAULT 0, notes TEXT,
      created_at TEXT DEFAULT (datetime("now"))
    );
    CREATE TABLE IF NOT EXISTS purchase_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT, purchase_id INTEGER,
      product_id INTEGER, product_name TEXT,
      qty REAL, unit_price REAL, line_total REAL
    );
    CREATE TABLE IF NOT EXISTS journal_entries (
      id INTEGER PRIMARY KEY AUTOINCREMENT, entry_number TEXT UNIQUE,
      date TEXT NOT NULL, description TEXT, reference TEXT,
      total_debit REAL DEFAULT 0, total_credit REAL DEFAULT 0,
      created_at TEXT DEFAULT (datetime("now"))
    );
    CREATE TABLE IF NOT EXISTS journal_lines (
      id INTEGER PRIMARY KEY AUTOINCREMENT, entry_id INTEGER,
      account_code TEXT, account_name TEXT,
      cost_center TEXT, debit REAL DEFAULT 0, credit REAL DEFAULT 0
    );
    CREATE TABLE IF NOT EXISTS chart_of_accounts (
      id INTEGER PRIMARY KEY AUTOINCREMENT, code TEXT UNIQUE,
      name TEXT, type TEXT, level INTEGER, parent_code TEXT
    );
    CREATE TABLE IF NOT EXISTS fixed_assets (
      id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
      purchase_date TEXT, original_value REAL DEFAULT 0,
      depreciation_rate REAL DEFAULT 20,
      accumulated_depreciation REAL DEFAULT 0,
      net_value REAL DEFAULT 0, status TEXT DEFAULT "نشط",
      created_at TEXT DEFAULT (date("now"))
    );
    CREATE TABLE IF NOT EXISTS expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL,
      category TEXT, description TEXT, amount REAL,
      payment_method TEXT DEFAULT "نقدي",
      created_at TEXT DEFAULT (datetime("now"))
    );
  `);
  seedDefaults();
}

function seedDefaults() {
  const s = db.prepare("INSERT OR IGNORE INTO settings(key,value) VALUES(?,?)");
  [["company_name","مؤسسة خالد التجارية"],["vat_number","310123456789003"],
   ["cr_number","1010000001"],["phone","0500000000"],
   ["address","الرياض - المملكة العربية السعودية"],
   ["tax_rate","15"],["inv_prefix","INV"],["pur_prefix","PUR"],["jv_prefix","JV"]
  ].forEach(r => s.run(r));

  const c = db.prepare("INSERT OR IGNORE INTO chart_of_accounts(code,name,type,level,parent_code) VALUES(?,?,?,?,?)");
  [["1","الأصول","مدين",1,null],["11","الأصول المتداولة","مدين",2,"1"],
   ["1101","الصندوق الرئيسي","مدين",3,"11"],["1102","البنك الراجحي","مدين",3,"11"],
   ["1103","ذمم مدينة - عملاء","مدين",3,"11"],["1104","مخزون البضاعة","مدين",3,"11"],
   ["12","الأصول غير المتداولة","مدين",2,"1"],
   ["1201","الأصول الثابتة","مدين",3,"12"],["1202","مجمع الإهلاك","دائن",3,"12"],
   ["2","الخصوم","دائن",1,null],["21","الخصوم المتداولة","دائن",2,"2"],
   ["2101","ذمم دائنة - موردون","دائن",3,"21"],
   ["2102","ضريبة القيمة المضافة المحصلة","دائن",3,"21"],
   ["2103","ضريبة القيمة المضافة المدخلات","مدين",3,"21"],
   ["3","حقوق الملكية","دائن",1,null],["3101","رأس المال","دائن",3,"3"],
   ["3102","الأرباح المحتجزة","دائن",3,"3"],
   ["4","الإيرادات","دائن",1,null],["4101","إيرادات المبيعات","دائن",3,"4"],
   ["4102","إيرادات متنوعة","دائن",3,"4"],
   ["5","المصروفات","مدين",1,null],["5101","تكلفة البضاعة المباعة","مدين",3,"5"],
   ["5102","مصاريف الرواتب","مدين",3,"5"],["5103","مصاريف الإيجار","مدين",3,"5"],
   ["5104","مصاريف الكهرباء","مدين",3,"5"],["5105","مصاريف الإهلاك","مدين",3,"5"],
   ["5106","مصاريف إدارية","مدين",3,"5"]
  ].forEach(r => c.run(r));
}

function cnt(tbl) { return db.prepare(`SELECT COUNT(*) c FROM ${tbl}`).get().c; }
function cfg() { return Object.fromEntries(db.prepare("SELECT key,value FROM settings").all().map(r=>[r.key,r.value])); }
function nextNum(prefix, tbl) { return prefix+"-"+String(cnt(tbl)+1).padStart(5,"0"); }

function autoJV(date, desc, ref, lines) {
  const td = lines.reduce((a,l)=>a+(+l.d||0),0);
  const tc = lines.reduce((a,l)=>a+(+l.c||0),0);
  const num = nextNum(cfg().jv_prefix||"JV","journal_entries");
  const id = db.prepare("INSERT INTO journal_entries(entry_number,date,description,reference,total_debit,total_credit) VALUES(?,?,?,?,?,?)").run(num,date,desc,ref,td,tc).lastInsertRowid;
  const ins = db.prepare("INSERT INTO journal_lines(entry_id,account_code,account_name,debit,credit) VALUES(?,?,?,?,?)");
  lines.forEach(l => ins.run(id,l.code,l.name,+l.d||0,+l.c||0));
}

function setupIPC() {
  ipcMain.handle("settings-get", () => cfg());
  ipcMain.handle("settings-save", (e,d) => {
    const s = db.prepare("INSERT OR REPLACE INTO settings(key,value) VALUES(?,?)");
    Object.entries(d).forEach(([k,v]) => s.run(k,v));
    return {ok:true};
  });

  ipcMain.handle("products-get", () => db.prepare("SELECT * FROM products WHERE is_active=1 ORDER BY name").all());
  ipcMain.handle("products-save", (e,p) => {
    if(p.id) {
      db.prepare("UPDATE products SET name=?,category=?,unit=?,cost_price=?,sell_price=?,qty=?,min_qty=?,barcode=? WHERE id=?")
        .run(p.name,p.category||"",p.unit||"قطعة",+p.cost_price||0,+p.sell_price||0,+p.qty||0,+p.min_qty||5,p.barcode||"",p.id);
    } else {
      const code = "P-"+String(cnt("products")+1).padStart(4,"0");
      db.prepare("INSERT INTO products(code,name,category,unit,cost_price,sell_price,qty,min_qty,barcode) VALUES(?,?,?,?,?,?,?,?,?)")
        .run(code,p.name,p.category||"",p.unit||"قطعة",+p.cost_price||0,+p.sell_price||0,+p.qty||0,+p.min_qty||5,p.barcode||"");
    }
    return {ok:true};
  });
  ipcMain.handle("products-delete", (e,id) => { db.prepare("UPDATE products SET is_active=0 WHERE id=?").run(id); return {ok:true}; });

  ipcMain.handle("customers-get", () => db.prepare("SELECT * FROM customers WHERE is_active=1 ORDER BY name").all());
  ipcMain.handle("customers-save", (e,c) => {
    if(c.id) db.prepare("UPDATE customers SET name=?,phone=?,email=?,vat_number=?,address=?,credit_limit=? WHERE id=?").run(c.name,c.phone||"",c.email||"",c.vat_number||"",c.address||"",+c.credit_limit||0,c.id);
    else db.prepare("INSERT INTO customers(name,phone,email,vat_number,address,credit_limit) VALUES(?,?,?,?,?,?)").run(c.name,c.phone||"",c.email||"",c.vat_number||"",c.address||"",+c.credit_limit||0);
    return {ok:true};
  });

  ipcMain.handle("suppliers-get", () => db.prepare("SELECT * FROM suppliers WHERE is_active=1 ORDER BY name").all());
  ipcMain.handle("suppliers-save", (e,s) => {
    if(s.id) db.prepare("UPDATE suppliers SET name=?,phone=?,email=?,vat_number=?,address=? WHERE id=?").run(s.name,s.phone||"",s.email||"",s.vat_number||"",s.address||"",s.id);
    else db.prepare("INSERT INTO suppliers(name,phone,email,vat_number,address) VALUES(?,?,?,?,?)").run(s.name,s.phone||"",s.email||"",s.vat_number||"",s.address||"");
    return {ok:true};
  });

  ipcMain.handle("invoices-get", () => db.prepare("SELECT i.*,c.name cname FROM invoices i LEFT JOIN customers c ON i.customer_id=c.id ORDER BY i.id DESC LIMIT 500").all());
  ipcMain.handle("invoices-save", (e,data) => {
    const {inv,items} = data;
    const num = nextNum(cfg().inv_prefix||"INV","invoices");
    const id = db.prepare("INSERT INTO invoices(invoice_number,customer_id,date,subtotal,discount,tax_amount,total,payment_method,notes) VALUES(?,?,?,?,?,?,?,?,?)")
      .run(num,inv.customer_id||null,inv.date,inv.subtotal,inv.discount||0,inv.tax_amount,inv.total,inv.payment_method||"نقدي",inv.notes||"").lastInsertRowid;
    const si = db.prepare("INSERT INTO invoice_items(invoice_id,product_id,product_name,qty,unit_price,discount,line_total) VALUES(?,?,?,?,?,?,?)");
    const up = db.prepare("UPDATE products SET qty=qty-? WHERE id=?");
    items.forEach(it => { si.run(id,it.pid||null,it.name,it.qty,it.price,it.disc||0,it.total); if(it.pid) up.run(it.qty,it.pid); });
    autoJV(inv.date,"مبيعات - "+num,num,[
      {code:"1101",name:"الصندوق الرئيسي",d:inv.total,c:0},
      {code:"4101",name:"إيرادات المبيعات",d:0,c:inv.subtotal},
      {code:"2102",name:"ضريبة القيمة المضافة المحصلة",d:0,c:inv.tax_amount}
    ]);
    return {ok:true, num};
  });
  ipcMain.handle("invoices-items", (e,id) => db.prepare("SELECT * FROM invoice_items WHERE invoice_id=?").all(id));

  ipcMain.handle("purchases-get", () => db.prepare("SELECT p.*,s.name sname FROM purchases p LEFT JOIN suppliers s ON p.supplier_id=s.id ORDER BY p.id DESC").all());
  ipcMain.handle("purchases-save", (e,data) => {
    const {pur,items} = data;
    const num = nextNum(cfg().pur_prefix||"PUR","purchases");
    const id = db.prepare("INSERT INTO purchases(purchase_number,supplier_id,date,subtotal,tax_amount,total,notes) VALUES(?,?,?,?,?,?,?)")
      .run(num,pur.supplier_id||null,pur.date,pur.subtotal,pur.tax_amount,pur.total,pur.notes||"").lastInsertRowid;
    const sp = db.prepare("INSERT INTO purchase_items(purchase_id,product_id,product_name,qty,unit_price,line_total) VALUES(?,?,?,?,?,?)");
    const up = db.prepare("UPDATE products SET qty=qty+?,cost_price=? WHERE id=?");
    items.forEach(it => { sp.run(id,it.pid||null,it.name,it.qty,it.price,it.total); if(it.pid) up.run(it.qty,it.price,it.pid); });
    autoJV(pur.date,"مشتريات - "+num,num,[
      {code:"5101",name:"تكلفة البضاعة المباعة",d:pur.subtotal,c:0},
      {code:"2103",name:"ضريبة القيمة المضافة المدخلات",d:pur.tax_amount,c:0},
      {code:"2101",name:"ذمم دائنة - موردون",d:0,c:pur.total}
    ]);
    return {ok:true, num};
  });

  ipcMain.handle("journal-get", () => db.prepare("SELECT * FROM journal_entries ORDER BY id DESC LIMIT 300").all());
  ipcMain.handle("journal-lines", (e,id) => db.prepare("SELECT * FROM journal_lines WHERE entry_id=?").all(id));
  ipcMain.handle("journal-save", (e,data) => {
    const {entry,lines} = data;
    const td = lines.reduce((a,l)=>a+(+l.d||0),0);
    const tc = lines.reduce((a,l)=>a+(+l.c||0),0);
    if(Math.abs(td-tc)>0.01) return {ok:false,err:`القيد غير متوازن: مدين=${td.toFixed(2)} دائن=${tc.toFixed(2)}`};
    const num = nextNum(cfg().jv_prefix||"JV","journal_entries");
    const id = db.prepare("INSERT INTO journal_entries(entry_number,date,description,total_debit,total_credit) VALUES(?,?,?,?,?)").run(num,entry.date,entry.desc,td,tc).lastInsertRowid;
    const s = db.prepare("INSERT INTO journal_lines(entry_id,account_code,account_name,cost_center,debit,credit) VALUES(?,?,?,?,?,?)");
    lines.forEach(l => s.run(id,l.code,l.name,l.center||"",+l.d||0,+l.c||0));
    return {ok:true, num};
  });

  ipcMain.handle("coa-get", () => db.prepare("SELECT * FROM chart_of_accounts ORDER BY code").all());
  ipcMain.handle("trial-get", () => db.prepare(`
    SELECT c.code,c.name,c.type,
      COALESCE(SUM(l.debit),0) td, COALESCE(SUM(l.credit),0) tc
    FROM chart_of_accounts c
    LEFT JOIN journal_lines l ON l.account_code=c.code
    WHERE c.level=3 GROUP BY c.code ORDER BY c.code
  `).all());

  ipcMain.handle("assets-get", () => db.prepare("SELECT * FROM fixed_assets ORDER BY id DESC").all());
  ipcMain.handle("assets-save", (e,a) => {
    const y = Math.max(0,(Date.now()-new Date(a.purchase_date))/(1000*60*60*24*365));
    const acc = Math.min(+a.original_value*(+a.depreciation_rate/100)*y, +a.original_value);
    db.prepare("INSERT INTO fixed_assets(name,purchase_date,original_value,depreciation_rate,accumulated_depreciation,net_value) VALUES(?,?,?,?,?,?)")
      .run(a.name,a.purchase_date,+a.original_value,+a.depreciation_rate||20,Math.round(acc),+a.original_value-Math.round(acc));
    return {ok:true};
  });

  ipcMain.handle("expenses-get", () => db.prepare("SELECT * FROM expenses ORDER BY date DESC").all());
  ipcMain.handle("expenses-save", (e,x) => {
    db.prepare("INSERT INTO expenses(date,category,description,amount,payment_method) VALUES(?,?,?,?,?)").run(x.date,x.cat,x.desc||"",+x.amount,x.pay||"نقدي");
    return {ok:true};
  });

  ipcMain.handle("dashboard", () => {
    const t = new Date().toISOString().split("T")[0];
    const ym = t.substring(0,7);
    return {
      today_sales: db.prepare("SELECT COALESCE(SUM(total),0) v FROM invoices WHERE date=?").get(t).v,
      today_count: db.prepare("SELECT COUNT(*) v FROM invoices WHERE date=?").get(t).v,
      today_tax:   db.prepare("SELECT COALESCE(SUM(tax_amount),0) v FROM invoices WHERE date=?").get(t).v,
      month_sales: db.prepare("SELECT COALESCE(SUM(total),0) v FROM invoices WHERE substr(date,1,7)=?").get(ym).v,
      total_prods: db.prepare("SELECT COUNT(*) v FROM products WHERE is_active=1").get().v,
      low_stock:   db.prepare("SELECT COUNT(*) v FROM products WHERE qty<=min_qty AND is_active=1").get().v,
      total_invs:  db.prepare("SELECT COUNT(*) v FROM invoices").get().v,
      recent_invs: db.prepare("SELECT i.invoice_number,i.date,i.total,c.name cname FROM invoices i LEFT JOIN customers c ON i.customer_id=c.id ORDER BY i.id DESC LIMIT 8").all(),
      low_items:   db.prepare("SELECT name,qty,min_qty FROM products WHERE qty<=min_qty AND is_active=1 LIMIT 6").all(),
      monthly:     db.prepare("SELECT substr(date,6,2) m,SUM(total) v FROM invoices WHERE substr(date,1,4)=? GROUP BY m ORDER BY m").all(t.substring(0,4)),
    };
  });

  ipcMain.handle("reports", () => ({
    sales:     db.prepare("SELECT COALESCE(SUM(subtotal),0) v FROM invoices").get().v,
    tax_out:   db.prepare("SELECT COALESCE(SUM(tax_amount),0) v FROM invoices").get().v,
    purchases: db.prepare("SELECT COALESCE(SUM(subtotal),0) v FROM purchases").get().v,
    tax_in:    db.prepare("SELECT COALESCE(SUM(tax_amount),0) v FROM purchases").get().v,
    expenses:  db.prepare("SELECT COALESCE(SUM(amount),0) v FROM expenses").get().v,
    assets:    db.prepare("SELECT COALESCE(SUM(net_value),0) v FROM fixed_assets").get().v,
    custs:     db.prepare("SELECT COUNT(*) v FROM customers WHERE is_active=1").get().v,
    sups:      db.prepare("SELECT COUNT(*) v FROM suppliers WHERE is_active=1").get().v,
    inv_count: db.prepare("SELECT COUNT(*) v FROM invoices").get().v,
  }));

  ipcMain.handle("backup", async () => {
    const {filePath} = await dialog.showSaveDialog(win,{
      defaultPath:"KhaledERP_"+new Date().toISOString().split("T")[0]+".db",
      filters:[{name:"Database",extensions:["db"]}]
    });
    if(filePath){ await db.backup(filePath); return {ok:true,path:filePath}; }
    return {ok:false};
  });
}

function createWindow() {
  win = new BrowserWindow({
    width:1440, height:900, minWidth:1200, minHeight:700,
    title:"نظام خالد للمحاسبة", backgroundColor:"#f3f4f6", show:false,
    webPreferences:{ nodeIntegration:false, contextIsolation:true, preload:path.join(__dirname,"preload.js") }
  });
  win.once("ready-to-show",()=>win.show());
  win.loadFile("src/index.html");
  Menu.setApplicationMenu(Menu.buildFromTemplate([
    {label:"ملف",submenu:[
      {label:"نسخة احتياطية",accelerator:"CmdOrCtrl+B",click:()=>win.webContents.executeJavaScript("doBackup()")},
      {type:"separator"},{label:"إغلاق",role:"quit"}
    ]},
    {label:"عرض",submenu:[{label:"ملء الشاشة",role:"togglefullscreen"},{label:"أدوات التطوير",role:"toggleDevTools"}]}
  ]));
}

app.whenReady().then(()=>{ initDB(); setupIPC(); createWindow(); });
app.on("window-all-closed",()=>{ if(process.platform!=="darwin") app.quit(); });
'@ | Set-Content "$AppDir\main.js" -Encoding utf8

# --- preload.js ---
@'
const { contextBridge, ipcRenderer } = require("electron");
contextBridge.exposeInMainWorld("erp", {
  settingsGet:    ()  => ipcRenderer.invoke("settings-get"),
  settingsSave:   (d) => ipcRenderer.invoke("settings-save",d),
  productsGet:    ()  => ipcRenderer.invoke("products-get"),
  productsSave:   (d) => ipcRenderer.invoke("products-save",d),
  productsDelete: (id)=> ipcRenderer.invoke("products-delete",id),
  customersGet:   ()  => ipcRenderer.invoke("customers-get"),
  customersSave:  (d) => ipcRenderer.invoke("customers-save",d),
  suppliersGet:   ()  => ipcRenderer.invoke("suppliers-get"),
  suppliersSave:  (d) => ipcRenderer.invoke("suppliers-save",d),
  invoicesGet:    ()  => ipcRenderer.invoke("invoices-get"),
  invoicesSave:   (d) => ipcRenderer.invoke("invoices-save",d),
  invoicesItems:  (id)=> ipcRenderer.invoke("invoices-items",id),
  purchasesGet:   ()  => ipcRenderer.invoke("purchases-get"),
  purchasesSave:  (d) => ipcRenderer.invoke("purchases-save",d),
  journalGet:     ()  => ipcRenderer.invoke("journal-get"),
  journalLines:   (id)=> ipcRenderer.invoke("journal-lines",id),
  journalSave:    (d) => ipcRenderer.invoke("journal-save",d),
  coaGet:         ()  => ipcRenderer.invoke("coa-get"),
  trialGet:       ()  => ipcRenderer.invoke("trial-get"),
  assetsGet:      ()  => ipcRenderer.invoke("assets-get"),
  assetsSave:     (d) => ipcRenderer.invoke("assets-save",d),
  expensesGet:    ()  => ipcRenderer.invoke("expenses-get"),
  expensesSave:   (d) => ipcRenderer.invoke("expenses-save",d),
  dashboard:      ()  => ipcRenderer.invoke("dashboard"),
  reports:        ()  => ipcRenderer.invoke("reports"),
  backup:         ()  => ipcRenderer.invoke("backup"),
});
'@ | Set-Content "$AppDir\preload.js" -Encoding utf8

Write-Host "✅ الدفعة الأولى مكتملة!" -ForegroundColor Green
Write-Host "   تم إنشاء: package.json + main.js + preload.js" -ForegroundColor Cyan
