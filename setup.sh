#!/bin/bash
# Run from the project root: bash setup.sh
# Installs PostgreSQL if missing, creates the database, and runs all SQL scripts.

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
DB_NAME="kickstarter"

cd "$PROJECT_DIR"

# ── 1. Install PostgreSQL if not present ──────────────────────
if ! command -v psql &>/dev/null; then
    echo "Installing PostgreSQL..."
    sudo apt-get update -qq
    sudo apt-get install -y postgresql postgresql-contrib
fi

# ── 2. Start the service ──────────────────────────────────────
sudo systemctl start postgresql
sudo systemctl enable postgresql

# ── 3. Create database ────────────────────────────────────────
if ! sudo -u postgres psql -lqt | cut -d'|' -f1 | grep -qw "$DB_NAME"; then
    echo "Creating database '$DB_NAME'..."
    sudo -u postgres createdb "$DB_NAME"
else
    echo "Database '$DB_NAME' already exists, skipping create."
fi

# ── 4. Grant current user access (so you can run psql without sudo) ──
CURRENT_USER="$(whoami)"
sudo -u postgres psql -c "
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$CURRENT_USER') THEN
            CREATE ROLE $CURRENT_USER LOGIN;
        END IF;
    END
    \$\$;
    GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $CURRENT_USER;
" 2>/dev/null || true

# ── 5. Run SQL scripts in order ───────────────────────────────
run() {
    echo ""
    echo ">>> $1"
    sudo -u postgres psql -d "$DB_NAME" -f "$PROJECT_DIR/$1"
}

run sql/01_create_schema.sql
run sql/02_import_data.sql
run sql/03_eda.sql
run sql/04_clean_data.sql

echo ""
echo ">>> Running analysis queries..."
for f in sql/05_*.sql sql/06_*.sql sql/07_*.sql sql/08_*.sql sql/09_*.sql \
          sql/10_*.sql sql/11_*.sql sql/12_*.sql sql/13_*.sql sql/14_*.sql \
          sql/15_*.sql; do
    echo "    $f"
    sudo -u postgres psql -d "$DB_NAME" -f "$PROJECT_DIR/$f" -q
done

run sql/16_views.sql

# ── 6. Export CSVs ────────────────────────────────────────────
echo ""
echo ">>> Exporting views to CSV..."
sudo -u postgres psql -d "$DB_NAME" -c "\COPY (SELECT * FROM vw_project_detail)   TO '$PROJECT_DIR/export_project_detail.csv'   CSV HEADER;"
sudo -u postgres psql -d "$DB_NAME" -c "\COPY (SELECT * FROM vw_category_summary) TO '$PROJECT_DIR/export_category_summary.csv' CSV HEADER;"
sudo -u postgres psql -d "$DB_NAME" -c "\COPY (SELECT * FROM vw_monthly_trend)    TO '$PROJECT_DIR/export_monthly_trend.csv'    CSV HEADER;"

echo ""
echo "Done. CSV exports are in the project root."
echo "  export_project_detail.csv"
echo "  export_category_summary.csv"
echo "  export_monthly_trend.csv"
