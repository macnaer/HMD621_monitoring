# Server Setup: Nagios Core on Ubuntu Server 26.04

Host: `10.7.99.103` (Ubuntu Server 26.04 LTS).
Phase 1 device: Cisco ISR4431/K9 at `10.7.0.101`.

Run the commands as a user with `sudo` rights. Replace placeholders before running.

## 1. Install Docker Engine

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl git ufw
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER"
```

Log out and log back in so the `docker` group takes effect, then check:

```bash
docker compose version
```

If the Docker repository does not yet provide packages for this Ubuntu release, the `apt-get install` step fails. Send the error output before continuing.

## 2. Firewall

Allow SSH and the web UI only from the admin network `10.7.0.0/16`. The SSH rule is added before `ufw enable` so the session stays open.

```bash
sudo ufw allow from 10.7.0.0/16 to any port 22 proto tcp
sudo ufw allow from 10.7.0.0/16 to any port 443 proto tcp
sudo ufw default deny incoming
sudo ufw enable
sudo ufw status verbose
```

## 3. Get the repository

```bash
cd ~
git clone https://github.com/macnaer/HMD621_monitoring.git
cd HMD621_monitoring/docker
```

## 4. Create the environment file

```bash
cp .env.example .env
chmod 600 .env
nano .env
```

Set `NAGIOS_ADMIN_PASSWORD` to a strong password. The `.env` file is ignored by Git and must stay on the server.

| Variable | Meaning |
|---|---|
| `TZ` | Container time zone |
| `NAGIOS_ADMIN_USER` | Web UI login |
| `NAGIOS_ADMIN_PASSWORD` | Web UI password (required) |
| `CERT_IP` | IP address in the self-signed certificate |

## 5. Build and start

```bash
docker compose up -d --build
docker compose ps
docker compose logs --tail=100 nagios
```

## 6. Validate the Nagios configuration

```bash
docker compose exec nagios /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
```

Expected result: no errors in the summary.

## 7. Open the web UI

From a host in `10.7.0.0/16`, open `https://10.7.99.103/nagios/`. The browser warns about the self-signed certificate. Check that the address matches `CERT_IP`, then accept the warning. Log in with `NAGIOS_ADMIN_USER` and `NAGIOS_ADMIN_PASSWORD`.

## Updates

```bash
cd ~/HMD621_monitoring
git pull
cd docker
docker compose up -d --build
```

## Configuration changes

After pulling changes to `nagios/conf.d/`, validate first and restart only if validation passes:

```bash
docker compose exec nagios /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
docker compose restart nagios
```

## Troubleshooting

- View logs: `docker compose logs -f nagios`
- Regenerate the certificate: `rm -f certs/nagios.crt certs/nagios.key`, then `docker compose restart nagios`
- Change the password: edit `.env`, then run `docker compose up -d`

## Scope of this runbook

This runbook covers the Nagios Core container only. It does not include device checks (added in a later PR) or Thruk (deferred until the Livestatus build is decided).
