# Database Facts (Drift / sqlite3)

## Key API facts for Drift 2.35 / sqlite3 3.5

- `IntColumn` is a typedef for `Column<int>` (NOT `GeneratedColumn`).
  - So table `primaryKey` overrides must be typed `Set<Column>`, not
    `Set<GeneratedColumn>`: `Set<Column> get primaryKey => {id};`
- Companions take **raw values** for required fields and `Value<T>` for
  optional ones. `Constant` is an `Expression`, NOT a `Value`.
- Insert API: both `db.table.insert(companion)` and
  `db.into(db.table).insert(...)` are valid. There is **no top-level**
  `into(...)`.
- Generated subclass constructor is `_$AppDatabase(QueryExecutor e) : super(e);`
  → hand-written subclass must use `super.e`.

## NativeDatabase open modes (Drift docs)

```dart
// read-write:
NativeDatabase(File(path))

// read-only:
NativeDatabase.opened(sqlite3.open(path, mode: OpenMode.readOnly))
```

- `OpenMode` comes from `package:sqlite3/sqlite3.dart`.

## Drift migrations must be idempotent

Drift only bumps `user_version` after `onUpgrade` completes, so a crash mid-migration leaves the DB half-migrated and re-runs `from < N` guards. Use raw `ALTER TABLE ... ADD COLUMN` guarded by a `PRAGMA table_info()` check (see `_addColumnIfMissing` in database.dart). Note: `m.addColumn` is NOT a no-op for existing columns (it throws "duplicate column name").

## customSelect variables parameter

Reading raw rows (`QueryRow`) from `customSelect`: use
`row.data['col']`, NOT `row.read('col')` (the latter throws
"Could not find a matching SQL type for dynamic" because the column has no
drift type mapping).

```dart
// Correct: named parameter with list of variables
db.customSelect(
  'SELECT col1, col2 FROM table WHERE id = ?',
  variables: [Variable(id)], // ← named! not positional []
)
```

## Drift_dev pluralization quirk & fix

Table `Wallboxes` → data class `Wallboxe`. Fixed with:

```dart
@DataClassName('Wallbox')
class Wallboxes extends Table { ... }
```

(Import `@DataClassName` from drift.)
