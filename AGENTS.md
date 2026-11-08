# AGENTS.md

Project instructions for AI agents working in this repository.

## Project

Monitoring system for network equipment and servers:

- Cisco switches and routers (IOS, IOS-XE, NX-OS)
- Hikvision IP cameras
- Linux servers

Repository: `macnaer/HMD621_monitoring`. Default branch: `master`.

Phase 1 covers one device: Cisco ISR4431/K9 running IOS-XE 17.9.5a at 10.7.0.101, monitored from Ubuntu Server 26.04 LTS at 10.7.99.103. Hikvision cameras and Linux servers come in later phases.

The phase 1 stack is defined in `docs/adr/0001-monitoring-stack.md`. Treat that ADR as the source of truth for phase 1 decisions.

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

## Skills (mandatory approach)

Create and maintain skills according to the Agent Skills specification at https://agentskills.io.

- Each skill is a directory containing a `SKILL.md` file.
- The directory name must match the `name` field.
- `name`: 1 to 64 characters, lowercase letters, digits, and hyphens only. No leading, trailing, or consecutive hyphens.
- `description`: 1 to 1024 characters. Describe what the skill does and when to use it, and include keywords.
- Optional directories: `scripts/`, `references/`, `assets/`.
- Keep `SKILL.md` under 500 lines. Move detailed material into `references/` and keep references one level deep.

## Architecture

- Do not change the phase 1 stack without a new ADR that the user approves.
- Deferred items: LibreNMS, SNMP traps, Telegram notifications, Hikvision cameras, and Linux servers.
- When a choice is needed, present 2 to 3 options with trade-offs, recommend one, and wait for approval.
- State assumptions explicitly. Ask questions when requirements are missing.
- Design for scale: use sensible polling intervals, timeouts, and retries so devices are not overloaded.

### Device guidance

- **Cisco IOS-XE:** phase 1 uses SNMPv2c with a read-only community restricted by ACL, as agreed in the ADR. Prefer SNMPv3 for future phases. Typical MIBs: CISCO-PROCESS-MIB (CPU), CISCO-MEMORY-POOL-MIB (memory), IF-MIB (interfaces), CISCO-ENVMON-MIB (sensors), SNMPv2-MIB (uptime). Verify OIDs with an SNMP walk on the device before using them.
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

- Configuration is plain text in the repository and is mounted into the container.
- Validate configuration with `nagios -v` before reloading. Include this step in every runbook.

## Response style

- Be concise and structured. Use tables for comparisons.
- Make trade-offs explicit and avoid unexplained jargon.
- Use file paths in backticks.
- Do not invent device capabilities or OIDs. If unsure, say so and explain how to verify.
