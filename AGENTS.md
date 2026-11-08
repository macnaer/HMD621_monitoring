# AGENTS.md

Project instructions for AI agents working in this repository.

## Project

Monitoring system for network equipment and servers:

- Cisco switches and routers (IOS, IOS-XE, NX-OS)
- Hikvision IP cameras
- Linux servers

Repository: `macnaer/HMD621_monitoring`. Default branch: `master`.

Phase 1 covers one device: Cisco ISR4431/K9 running IOS-XE 17.9.5a at 10.7.0.101, monitored by Nagios Core in Docker on Ubuntu Server 26.04 LTS at 10.7.99.103. Hikvision cameras and Linux servers come in later phases. The current status is in `README.md`.

The phase 1 stack is defined in `docs/adr/0001-monitoring-stack.md`. Treat that ADR as the source of truth for phase 1 decisions.

## Environment

- Monitoring host: Ubuntu Server 26.04 LTS at `10.7.99.103`. Docker Engine runs the Nagios container with host networking. Run Compose commands from the `docker/` directory.
- Web UI: reachable from the admin network `10.7.0.0/16` on port 443 only. Enforced with ufw.
- Phase 1 device: Cisco ISR4431/K9 at `10.7.0.101`. The router accepts SNMPv2c read-only requests only from `10.7.99.103`.
- The server also runs containers this project does not own: a container named `nagios` (image `macnaer/nagios`) and a LibreNMS stack with an SNMP trap receiver on UDP 162. Do not stop, remove, or reconfigure them.
- The user runs all commands on the server and sends the output back. The agent has no direct access to the server.
- The agent works in the user's local clone of this repository.

## Role

Help plan architecture, technology choices, and technical details. Write code, configuration, and documentation under the approval and Git rules below.

## Language (mandatory)

- All code, code comments, documentation, configuration files, commit messages, branch names, pull request titles and descriptions, and skill files MUST be written in English.
- Reply to the user in the language they use in conversation.

## Approval (mandatory)

- Ask the user and wait for an explicit "yes" before any action that changes state. This includes creating, editing, or deleting files; creating branches, commits, pull requests, or issues; running shell commands; installing packages; creating or changing skills; and calling external services that modify data.
- Before acting, state exactly what you will do and where, and show the exact content or command.
- An approval covers only the action described. Ask again for the next action.
- Discussion and drafts in the conversation do not require approval.
- Reading files in the project folder or reading the GitHub repository does not require approval. Say which files you read.

## Git and pull requests (mandatory)

- NEVER push to `master`. NEVER commit directly to `master`.
- Every change goes through a feature branch and a pull request into `master`.
- Branch names: `feature/<short-description>`, `fix/<short-description>`, `docs/<short-description>`.
- Before opening a pull request, check for `.github/pull_request_template.md` and fill in every section.
- Pull request titles and descriptions are in English.
- Commit messages are in English, in the imperative mood, and describe the change.
- Do not force-push, delete branches, or close pull requests without explicit approval.
- The user merges pull requests. Do not merge them.
- The user pulls merged changes with `git pull` and runs them on the server. Put runbooks and deployment steps in the repository so they can be followed without questions.
- Before starting new work, switch to `master` and fast-forward it: `git checkout master`, then `git pull --ff-only origin master`.
- Standing approval: after the user confirms that a pull request was merged, the agent may run the sync above without asking again. Other Git actions still require approval.
- Repository files use LF line endings. Windows checkouts may show CRLF (`core.autocrlf`), but committed files must be LF. Shell scripts must be LF because they run in Linux containers.

## Skills (mandatory approach)

Create and maintain skills according to the Agent Skills specification at https://agentskills.io.

- Project skills live in `.opencode/skills/<skill-id>/SKILL.md` and are committed to the repository.
- The skill ID is the directory name: 1 to 64 characters, lowercase letters, digits, and single hyphens. It must not start or end with a hyphen.
- The frontmatter `name` matches the directory name. `description` is 1 to 1024 characters and says what the skill does and when to use it, with keywords.
- Optional directories: `scripts/`, `references/`, `assets/`. Keep `SKILL.md` under 500 lines. Move detailed material into `references/` and keep references one level deep.
- Do not create or change skills without approval.

## Architecture

- Do not change the phase 1 stack without a new ADR that the user approves.
- Deferred items: LibreNMS, SNMP traps, Telegram notifications, Hikvision cameras, and Linux servers.
- When a choice is needed, present 2 to 3 options with trade-offs, recommend one, and wait for approval.
- State assumptions explicitly. Ask questions when requirements are missing.
- Design for scale: use sensible polling intervals, timeouts, and retries so devices are not overloaded.

### Device guidance

- **Cisco IOS-XE:** phase 1 uses SNMPv2c with a read-only community restricted by ACL, as agreed in the ADR. Prefer SNMPv3 for future phases. Typical MIBs: CISCO-PROCESS-MIB (CPU), CISCO-MEMORY-POOL-MIB (memory), IF-MIB (interfaces), CISCO-ENVMON-MIB (sensors), SNMPv2-MIB (uptime). Verify OIDs with an SNMP walk on the device before using them. Use numeric OIDs in commands so MIB files are not required.
- **Hikvision:** use the vendor ISAPI over HTTPS with digest authentication. Consider ONVIF and RTSP for stream checks. Change default credentials. Keep firmware updated (for example, CVE-2021-36260).
- **Linux:** choose agent-based or agentless collection and explain the trade-off. Use key-based SSH and least-privilege accounts.

### Network and security

- Place cameras and device management interfaces in management VLANs.
- Restrict access to monitoring web interfaces to the admin network and use HTTPS.
- Never hardcode credentials. Never commit secrets, SNMP community strings, API tokens, or chat IDs.
- Keep real secrets in `.env` on the server, which Git ignores, or in a secrets manager. Commit only `.env.example` with placeholders.
- Use placeholders in examples and documentation, such as `<SNMP_RO_COMMUNITY>` and `<TELEGRAM_BOT_TOKEN>`.
- Redact secrets from logs, examples, and documentation.

## Nagios configuration

- Object configuration lives in `nagios/conf.d/*.cfg`. The directory is mounted read-only into the container at `/usr/local/nagios/etc/conf.d`.
- Validate before every restart: `docker compose exec nagios /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg`. Expect `Total Errors: 0`. Restart with `docker compose restart nagios` only after validation passes.
- The container is named `hmd621-nagios`. The Compose service name is `nagios`.
- Macros: `$USER1$` is the plugin directory. `$USER5$` is the SNMP read-only community, written by the entrypoint from `SNMP_RO_COMMUNITY` in `docker/.env`. Never put community strings in `.cfg` files or in the repository.
- Notifications stay disabled until Telegram is implemented.
- Phase 1 thresholds: CPU warning 80%, critical 90%. Memory warning 85%, critical 95%. Check interval 5 minutes.

## Response style

- Be concise and structured. Use tables for comparisons.
- Make trade-offs explicit and avoid unexplained jargon.
- Use file paths in backticks.
- Do not invent device capabilities or OIDs. If unsure, say so and explain how to verify.
