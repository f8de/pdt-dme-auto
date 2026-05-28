# DME Auto — Project Instructions

## Deployment Model

**Nothing gets installed on the server or workstations.**
Distribution is always a single EXE built via PyInstaller.

```
python build.py [patch|minor|major]   # builds dist/dme-auto.exe + deploy/
build.bat [patch|minor|major]         # same, via batch
```

- Credentials come from Doppler at runtime — never bundled
- Config files (`config/*.json`) are bundled via `packaging/dmeworks.spec` `datas`
- Deploy artifact: `deploy/dme-auto.exe` — copy this to the workstation, nothing else

## Adding New Dependencies

Before adding any new `pip install`:

1. **Can it be avoided?** Prefer stdlib or already-present packages.
2. **Pin the version** in `requirements.txt` to avoid pulling in breaking upgrades.
3. **Add hidden imports** to `packaging/dmeworks.spec` → `hiddenimports` if the package
   uses dynamic imports (most connector/plugin packages do).
4. **Add excludes** for sub-modules that are unused — check `excludes` list in the spec.
5. **Check EXE size** after build (`build.bat` prints MB). Investigate if size jumps > 5 MB.

Size budget: keep `dme-auto.exe` under ~50 MB. Current excludes in spec already strip:
tkinter, sqlite3, stdlib servers, test/dev tools, win32comext.

## Databases

| Code | Name      | Purpose          |
|------|-----------|------------------|
| c02  | allied    | production       |
| dmeworks | shared | shared schema  |

`db.configure(database)` must be called before any query — sets active DB for entire session,
including which MIR stored procs are called.

## Testing

```bash
pytest tests/                      # unit tests, no DB needed (all mocked)
python ingest_test.py              # dry-run validation
python ingest_test.py --live       # real writes to c02 + field-level verify
```

## Key Rules

- Parameterized SQL only — never f-strings or string concat in queries
- `db.configure()` before queries — raises `RuntimeError` if skipped
- `use_pure=True` in connection params — MySQL 5.7 server, pin connector `==8.0.33`
  (8.4+ and 9.x both dropped `mysql_native_password` support)
- Secrets in `secrets/` via Doppler — never `.env`, never hardcoded
