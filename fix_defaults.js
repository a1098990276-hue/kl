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
    const colType = c.type && c.type.trim() ? c.type : "TEXT";
    let def = c.dflt_value;
    if (def && /datetime|strftime|\(|now\(|CURRENT_TIMESTAMP/i.test(def)) {
      def = "CURRENT_TIMESTAMP";
    }
    const notnull = c.notnull ? " NOT NULL" : "";
    const pk = c.pk ? " PRIMARY KEY" : "";
    return '"' + colName + '" ' + colType + notnull + (def ? " DEFAULT " + def : "") + pk;
  }).join(", ");
  const createSQL = 'CREATE TABLE "' + name + '" (' + colDefs + ');';
  db.exec(createSQL);
  const colList = cols.map(c => '"' + c.name + '"').join(", ");
  db.exec('INSERT INTO "' + name + '" (' + colList + ') SELECT ' + colList + ' FROM "' + name + '_old";');
  db.exec('DROP TABLE "' + name + '_old";');
}
console.log("✔ تم إصلاح جميع الجداول بنجاح");
