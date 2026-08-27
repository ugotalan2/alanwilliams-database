# AlanWilliams Database

Shared PostgreSQL runtime for the AlanWilliams Apps ecosystem.

## Purpose

`alanwilliams-database` owns the shared PostgreSQL container, persistent database volume, and database-level operational tooling used by the AlanWilliams Apps platform.

It does **not** own application schemas or Flyway migrations. Each app continues to own its own database and migrations.

```text
PostgreSQL container
├── platform_dev / platform_test / platform_prod
├── agenda_dev / agenda_test / agenda_prod
├── budget_dev / budget_test / budget_prod
└── future app databases
```

Applications connect to the shared PostgreSQL service over the `alanwilliams-backend` Docker network.

## Ownership

This repository owns:

- PostgreSQL container lifecycle
- persistent PostgreSQL Docker volume
- shared `alanwilliams-backend` Docker network
- database creation tooling
- backup / restore tooling
- PostgreSQL version upgrades

Application repositories own:

- their own database schema
- Flyway migrations
- JPA entities
- application database configuration
- application data retention rules

## Local Development

Copy the local environment template:

```bash
cp .env.example .env
```

Start PostgreSQL:

```bash
docker compose up -d
```

Verify it:

```bash
docker compose ps
```

Create a database:

```bash
./scripts/create-database.sh platform_dev
```

List databases:

```bash
./scripts/list-databases.sh
```

Host connection example:

```text
jdbc:postgresql://localhost:5432/platform_dev
```

Docker connection example from another container on `alanwilliams-backend`:

```text
jdbc:postgresql://postgres:5432/platform_dev
```

## Adding Another App

A new app does not require another PostgreSQL container. Create another database and let that app own its schema through Flyway.

```bash
./scripts/create-database.sh budget_dev
```

## Backups

Logical backups use PostgreSQL custom format (`pg_dump -Fc`).

```bash
BACKUP_DATABASES="platform_dev" ./scripts/backup.sh
```

Multiple databases:

```bash
BACKUP_DATABASES="agenda_prod platform_prod" ./scripts/backup.sh
```

Default backup directory is `./backups`. Override it with `BACKUP_DIR`.

## Restore

Restore into a separate database:

```bash
./scripts/restore.sh backups/platform_dev-20260826-120000.dump platform_restore_test
```

Never test restores by overwriting production.

## Important Docker Rules

Do not run `docker compose down -v` on production unless you explicitly intend to destroy the PostgreSQL data volume.

Normal operations:

```bash
docker compose up -d
docker compose restart
docker compose pull
```

The named volume persists independently of container replacement.
