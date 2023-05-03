### 1.1.0

- Use `Thor` to make cli.
- Support `firefox` for automation.
- Fix incorrect syntax for many-to-many relation in Azimutt.
- Add path completion in cli.
- Rename `join_table` to `junction_table`.
- Add new commands in cli.
  - `erdb help` to show help.
  - `erdb version` to show version.
- Add new options in cli.
  - `--browser=BROWSER` to specify browser.
  - `--junction-table` to show junction table.
  - `--no-junction-table` to hide junction table.

### 1.0.1

- Prioritize Interruption over Error cuz ActiveRecord is lazy load.

### 1.0.1

- Catch database error at runtime

### 1.0.0

- Initial release
- Added ERD generation for SQLite, PostgreSQL and MySQL
- Use [Azimutt](https://azimutt.app) to generate the diagrams
- Use [DBDiagram](https://dbdiagram.io) to generate the diagrams
