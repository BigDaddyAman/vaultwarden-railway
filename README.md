![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Vaultwarden](https://img.shields.io/badge/Vaultwarden-self--hosted-blue)
![Railway](https://img.shields.io/badge/deploy-Railway-purple)
![Docker](https://img.shields.io/badge/container-Docker-2496ED?logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/database-PostgreSQL-4169E1?logo=postgresql&logoColor=white)
![Storage](https://img.shields.io/badge/storage-Railway%20Volume-orange)

# Vaultwarden on Railway

Deploy your own [Vaultwarden](https://github.com/dani-garcia/vaultwarden) server on [Railway](https://railway.com/) with PostgreSQL and persistent storage.

This repository is a one-click Railway template for running a self-hosted Bitwarden-compatible password manager. It is an independent deployment project and is not an official Vaultwarden or Bitwarden project.

## 🚀 Deploy on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/vaultwarden-postgresql-self-hosted-passw?referralCode=nIQTyp&utm_medium=integration&utm_source=template&utm_campaign=generic)

This template provisions:

- the Vaultwarden application
- a PostgreSQL database
- a persistent Railway volume mounted at `/data`

Once deployment is complete, follow the setup steps below.

---

## After deployment

### 1. Open your Railway project

After deploying the template:

1. Open the new project in Railway.
2. Wait for the Vaultwarden and PostgreSQL services to finish deploying.
3. Check the Vaultwarden logs and confirm the app starts successfully.
4. Confirm the Vaultwarden service has a Railway Volume mounted at `/data`.
5. Confirm the PostgreSQL service is running and that Vaultwarden is using it.

The template should configure the app and database connection automatically. You typically should not need to create these services manually.

### 2. Configure your domain

In Railway:

1. Open the **Vaultwarden** service.
2. Go to **Settings → Networking**.
3. Generate a Railway domain or add your own custom domain.
4. Make sure HTTPS is enabled.
5. Open **Variables** and set `DOMAIN` to the full public URL.

Example:

```env
DOMAIN=https://vault.example.com
```

Replace `vault.example.com` with your real domain. Do not add a trailing slash.

If you use a Railway-generated domain, set `DOMAIN` to that domain with `https://`.

### 3. Create your first account

Public registration is disabled by default.

To create your first account:

1. Open the Vaultwarden service in Railway.
2. Go to **Variables**.
3. Temporarily set:

```env
SIGNUPS_ALLOWED=true
```

4. If you already saved settings in the Admin page, check **General Settings** there as well. Saved Admin settings can override environment variables.
5. Wait for Railway to apply the change and redeploy the service.
6. Open the signup page:

`https://vault.example.com/#/signup`

7. Create your account.

Use your own domain in place of `vault.example.com`.

> Choose a strong, unique master password and keep it safe. Vaultwarden cannot recover a forgotten master password.

### 4. Disable public registration

After creating the account(s) you need:

1. Set `SIGNUPS_ALLOWED=false` in Railway.
2. If the Admin page has a saved signup setting, turn off **Allow new signups** there as well.
3. Wait for the change to take effect.
4. Test the signup page in a private/incognito browser window to confirm public registration is disabled.

Keep public registration disabled unless you intentionally want to allow new users to register.

---

## Admin page

The Admin page is available at:

`https://vault.example.com/admin`

Replace the example domain with your own.

Access requires an `ADMIN_TOKEN`.

- To enable the Admin page, set `ADMIN_TOKEN` in Railway to an **Argon2 PHC hash** of your admin token.
- When signing in to `/admin`, enter the original plain-text token, not the hash.
- Keep the original token private and store it securely.
- If you do not need the Admin page, leave `ADMIN_TOKEN` unset.

Do not use an empty admin token as a substitute for securing the Admin page.

The Admin page manages server-wide settings. It is separate from each user’s personal vault and does not reveal users’ master passwords.

Settings saved through the Admin page may be stored in `/data/config.json` and can override environment variables. If a setting does not change after editing Railway Variables, check the corresponding Admin setting.

---

## Connect Bitwarden apps

Vaultwarden is compatible with Bitwarden clients.

1. Install the Bitwarden browser extension, desktop app, or mobile app from the official [Bitwarden downloads page](https://bitwarden.com/download/).
2. Before signing in, open the app’s **Server** or **Self-hosted environment** settings.
3. Set the server URL to your Vaultwarden address:

`https://vault.example.com`

4. Save the server setting.
5. Sign in with the account you created on your Vaultwarden server.

Use the same self-hosted server URL on every device. Do not use the default Bitwarden cloud server for an account stored on your Vaultwarden instance.

Enable 2FA in your account settings and store the recovery codes somewhere safe.

---

## Invitations and email

Invitations are disabled by default.

If you want to invite other users:

1. Set `INVITATIONS_ALLOWED=true` in Railway.
2. Configure SMTP settings before relying on email invitations or notifications.
3. Review the invitation-related settings in the Admin page.
4. Test the full invitation flow before inviting other users.

You can keep `SIGNUPS_ALLOWED=false` while using invitations. Disabling public registration does not prevent existing users from signing in.

If you do not need invitations, leave `INVITATIONS_ALLOWED=false`.

---

## Environment variables

The template is intended to use the following configuration. The exact Railway variable names may depend on the service names used in the template.

| Variable | Purpose |
| --- | --- |
| `DATA_FOLDER=/data` | Stores Vaultwarden application files in the persistent volume. |
| `DATABASE_URL` | PostgreSQL connection string. |
| `DOMAIN` | Public HTTPS address used by clients and generated links. Set this after configuring your domain. |
| `ROCKET_ADDRESS=0.0.0.0` | Makes the application listen on the container network. |
| `ROCKET_PORT=8080` | Application listening port; must match Railway’s service configuration. |
| `ROCKET_PROFILE=release` | Runs Rocket with the release profile. |
| `SIGNUPS_ALLOWED=false` | Disables public account registration by default. |
| `INVITATIONS_ALLOWED=false` | Disables invitations by default. |
| `ENABLE_WEBSOCKET=true` | Enables WebSocket support for live notifications and synchronization when supported by the deployed Vaultwarden version. |
| `SHOW_PASSWORD_HINT=false` | Hides password hints. |

Do not publish database credentials, admin tokens, SMTP passwords, or other secrets in this repository.

---

## Data persistence and backups

This deployment uses two separate persistent data locations:

- **PostgreSQL** — stores the Vaultwarden database.
- **Railway Volume mounted at `/data`** — stores Vaultwarden files.

Back up both locations regularly and test restoring them.

A database-only backup is not a complete recovery if files in `/data` are also needed. A `/data`-only backup does not contain the PostgreSQL database.

> A Railway Volume is persistent storage, not a backup. Do not delete either volume when redeploying or troubleshooting unless you have verified backups and a recovery plan.

---

## Updating Vaultwarden

If the deployment uses the `latest` image tag, a redeployment may pull a newer Vaultwarden version.

Before updating:

1. Check the [Vaultwarden releases](https://github.com/dani-garcia/vaultwarden/releases).
2. Back up PostgreSQL and the `/data` volume.
3. Deploy the update.
4. Check the Railway deployment logs.
5. Test login, vault access, and synchronization.

For more predictable deployments, consider pinning a specific Vaultwarden image version instead of using `latest`.

---

## Troubleshooting

### Signup page is unavailable

- Confirm `SIGNUPS_ALLOWED=true` if you intentionally want public registration.
- Check the Admin page’s saved **General Settings**.
- Wait for the Railway deployment to finish after changing variables.

### Users cannot create an account

- Confirm public registration is enabled, or that the user has a valid invitation.
- Check the Vaultwarden deployment logs.
- Check whether the Admin page is overriding the environment variable.

### Vaultwarden cannot connect to PostgreSQL

- Confirm `DATABASE_URL` references the correct PostgreSQL service and variable.
- Confirm the PostgreSQL service is running.
- Prefer Railway’s private database connection.
- Check the Vaultwarden deployment logs.
- Never paste database credentials into public issue reports.

### Changes do not appear on another device immediately

- Confirm the client is configured to use your self-hosted server URL.
- Check that WebSocket support is enabled and functioning for the deployed version.
- Check the browser or app network logs and Railway logs for connection errors.
- Try a manual sync while troubleshooting.

### Data appears missing after redeployment

- Confirm the Railway Volume is still attached at `/data`.
- Confirm `DATA_FOLDER=/data`.
- Confirm `DATABASE_URL` still points to the correct database.
- Do not delete volumes or initialize a replacement database until you have investigated and checked your backups.

---

## Security checklist

Before storing important credentials:

- [ ] HTTPS is enabled and `DOMAIN` matches the public URL.
- [ ] PostgreSQL is not unnecessarily exposed publicly.
- [ ] The Vaultwarden Railway Volume is mounted at `/data`.
- [ ] Public signups are disabled after account creation.
- [ ] Invitations are disabled unless needed.
- [ ] The Admin page is protected with an Argon2-hashed token, or disabled.
- [ ] Every user has a strong, unique master password.
- [ ] Two-factor authentication is enabled where possible.
- [ ] PostgreSQL and `/data` are both backed up.
- [ ] Restores have been tested.
- [ ] Vaultwarden is kept up to date.

---

## Run locally with Docker Compose

You can also run this project on your own computer for testing or personal use.

### Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/macOS), or Docker Engine with the Docker Compose plugin (Linux)
- Git, if you want to clone this repository

### 1. Clone the repository

```bash
git clone https://github.com/BigDaddyAman/vaultwarden-railway.git
cd vaultwarden-railway
```

### 2. Create your local environment file

Copy the example file:

**Windows CMD:**
```cmd
copy .env.example .env
```

**macOS / Linux:**
```bash
cp .env.example .env
```

Edit `.env` and set a strong local PostgreSQL password. For example:

```env
POSTGRES_DB=vaultwarden
POSTGRES_USER=vaultwarden
POSTGRES_PASSWORD=replace-with-a-long-random-password

DOMAIN=http://localhost:8080
SIGNUPS_ALLOWED=true
INVITATIONS_ALLOWED=false
SHOW_PASSWORD_HINT=false
ROCKET_ADDRESS=0.0.0.0
ROCKET_PORT=8080
ROCKET_PROFILE=release
DATA_FOLDER=/data
```

These values are for local development only. Do not reuse the example password in production or commit your `.env` file.

### 3. Create `compose.yaml`

Create a file named `compose.yaml` in the repository root:

```yaml
services:
  postgres:
    image: postgres:18-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-vaultwarden}
      POSTGRES_USER: ${POSTGRES_USER:-vaultwarden}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?Set POSTGRES_PASSWORD in .env}
    volumes:
      - postgres_data:/var/lib/postgresql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-vaultwarden} -d ${POSTGRES_DB:-vaultwarden}"]
      interval: 5s
      timeout: 5s
      retries: 10

  vaultwarden:
    build: .
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://${POSTGRES_USER:-vaultwarden}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB:-vaultwarden}
      DOMAIN: ${DOMAIN:-http://localhost:8080}
      DATA_FOLDER: /data
      ROCKET_ADDRESS: 0.0.0.0
      ROCKET_PORT: 8080
      ROCKET_PROFILE: release
      ADMIN_TOKEN: ${ADMIN_TOKEN:-}
      SIGNUPS_ALLOWED: ${SIGNUPS_ALLOWED:-false}
      INVITATIONS_ALLOWED: ${INVITATIONS_ALLOWED:-false}
      SHOW_PASSWORD_HINT: ${SHOW_PASSWORD_HINT:-false}
      ENABLE_WEBSOCKET: ${ENABLE_WEBSOCKET:-true}
    ports:
      - "8080:8080"
    volumes:
      - vaultwarden_data:/data

volumes:
  postgres_data:
  vaultwarden_data:
```

The PostgreSQL service and Vaultwarden data directory use separate named Docker volumes so their data survives container replacement.

### 4. Start the services

```bash
docker compose up -d --build
```

Open [http://localhost:8080](http://localhost:8080).

To view logs:

```bash
docker compose logs -f vaultwarden
```

### 5. Create your first account

For a fresh local instance, `SIGNUPS_ALLOWED=true` in `.env` allows account registration. Create your account, then set it to:

```env
SIGNUPS_ALLOWED=false
```

Apply the change:

```bash
docker compose up -d
```

Existing users can still sign in after public registration is disabled.

### 6. Stop or remove the local services

Stop the containers without deleting stored data:

```bash
docker compose down
```

Start them again later:

```bash
docker compose up -d
```

> Warning: The following command also deletes the named database and Vaultwarden data volumes. Do not run it unless you intentionally want to erase the local instance:

```bash
docker compose down -v
```

This local Compose setup is for development and self-hosting outside Railway. For production, use HTTPS, secure secrets, restrict access, and maintain independent backups of both PostgreSQL and the Vaultwarden `/data` volume.

---

## Useful links

- [Vaultwarden GitHub repository](https://github.com/dani-garcia/vaultwarden)
- [Vaultwarden Wiki](https://github.com/dani-garcia/vaultwarden/wiki)
- [Bitwarden downloads](https://bitwarden.com/download/)
- [Railway documentation](https://docs.railway.com/)

Vaultwarden is a third-party project. This repository is an independent Railway deployment template and is not affiliated with or endorsed by Bitwarden or the Vaultwarden maintainers.