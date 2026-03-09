/**
 * Promote a user to ADMIN role.
 * Usage: npx tsx scripts/promote-admin.ts <email>
 *
 * Requires DATABASE_URL or DB_HOST/DB_PORT/DB_USER/DB_PASSWORD/DB_NAME env vars.
 */
import pg from 'pg';
const { Client } = pg;

async function main() {
  const email = process.argv[2];
  if (!email) {
    console.error('Usage: npx tsx scripts/promote-admin.ts <email>');
    process.exit(1);
  }

  const connectionString = process.env.DATABASE_URL;
  const client = connectionString
    ? new Client({ connectionString })
    : new Client({
        host: process.env.DB_HOST || 'localhost',
        port: Number(process.env.DB_PORT) || 5432,
        user: process.env.DB_USER || 'postgres',
        password: process.env.DB_PASSWORD || 'postgres',
        database: process.env.DB_NAME || 'oracul',
      });

  try {
    await client.connect();

    // Add role column if it doesn't exist
    await client.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM information_schema.columns
          WHERE table_name = 'users' AND column_name = 'role'
        ) THEN
          CREATE TYPE "enum_users_role" AS ENUM ('USER', 'ADMIN');
          ALTER TABLE users ADD COLUMN role "enum_users_role" NOT NULL DEFAULT 'USER';
        END IF;
      END $$;
    `);

    // Promote user
    const result = await client.query(
      `UPDATE users SET role = 'ADMIN' WHERE email = $1 RETURNING id, email, role`,
      [email],
    );

    if (result.rowCount === 0) {
      console.error(`User with email "${email}" not found.`);
      process.exit(1);
    }

    console.log(`User promoted to ADMIN:`, result.rows[0]);
  } finally {
    await client.end();
  }
}

main().catch((err) => {
  console.error('Error:', err.message);
  process.exit(1);
});
