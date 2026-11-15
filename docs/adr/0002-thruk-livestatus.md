# ADR 0002: Thruk Web UI with Livestatus

- Status: Accepted (implementation pending)
- Date: 2026-11-15

## Context

ADR 0001 selected Thruk in a separate container as the web UI, but the phase 1 deployment runs the native Nagios Core CGI interface and README lists Thruk as "deferred, depends on Livestatus build". This ADR records the implementation decisions so the build can proceed without re-litigating the stack.

Reference implementation analyzed: `macnaer/cmr621_monitoring` (OMD Labs image, Naemon core, Thruk UI, Ansible-driven config, Jenkins CI).

Practices adopted from it:

- The admin password is applied by the container entrypoint from an ignored local secret file, never from the repository.
- Configuration validation runs before every restart of the core.
- Lockout recovery for the web UI is documented in the runbook.
- After a deployment, verify that the UI actually lists every monitored host.

Not adopted:

- OMD/Naemon stack. ADR 0001 keeps Nagios Core; Thruk connects to it through Livestatus.
- Ansible rendering of object configuration at container start. Our object configuration stays plain files in `nagios/conf.d/`, changed only through pull requests.
- Jenkins CI. Deferred until the deployment cadence justifies it.

## Decision

- **Thruk image:** own image `docker/thruk/Dockerfile` based on `ubuntu:24.04`, installing the official Thruk 3.30 packages for Ubuntu 24.04 from `https://download.thruk.org/pkg/v3.30/ubuntu24.04/amd64/` (`libthruk_3.26_ubuntu24.04_amd64.deb`, `thruk-base_3.30-1_ubuntu24.04_amd64.deb`), pinned by version and checksum in the Dockerfile. Community images (`micwy/thruk`, `mmerian/thruk`) are stale and not used.
- **Livestatus module:** built from the fork `EdCa361/mk_livestatus-for-Nagios-4.5.X` at pinned commit `42f8eafb96706e2b0025e285a31637106345acd8` (Nagios 4.5.9 headers, includes the timeperiod-cache log fix). Fallback if the ABI check fails at runtime: upstream mk-livestatus 1.2.8 built with the Nagios Core 4.5.14 headers.
- **Transport:** one shared Docker volume mounted at `/run/livestatus` in both containers. Nagios writes the socket there, Thruk reads it. No TCP listener for Livestatus.
- **Ports:** Thruk listens on `0.0.0.0:443` and is the primary web UI. The Nagios CGI interface moves to `127.0.0.1:8080` and is not reachable from the network. Port 8443 is not used because the `cmr621-monitoring` container already binds it on this host.
- **Firewall:** unchanged. The existing ufw rule allows `443/tcp` from `10.7.0.0/16` only. Opening access beyond the admin network is not approved.
- **Nagios container:** keeps `network_mode: host` for SNMP source addressing; the CGI port change is an Apache listen-address change inside the container, not a network-mode change.

## Consequences

- The primary web UI URL becomes `https://10.7.99.103/` (Thruk). The runbook and README must be updated when the switch is implemented.
- Thruk gets command access (acknowledgements, downtimes) through the Livestatus socket. The socket lives only in the shared volume and is never exposed on the network.
- Livestatus ABI mismatch with Nagios Core 4.5.14 is the main build risk. Mitigation: pinned fork, plus the documented 1.2.8 fallback, plus verification that the module logs `initialized successfully` before the UI is considered working.
- The Thruk image pulls Apache and Perl dependencies and is noticeably larger than the Nagios image. Accepted for phase 1.
- Two web containers run on the host; only Thruk publishes a port. The old CGI stays available locally for troubleshooting.

## Open items

- Exact Apache/HTTPS vhost configuration inside the Thruk image and certificate handling (separate `certs/thruk.crt` or shared certificate).
- Authentication mode for the first version: Thruk cookie authentication (the package default) versus plain HTTP basic auth.
- SHA-256 checksums for the two `.deb` files, recorded in the Dockerfile when the image is first built.
- Post-deploy verification steps added to `docs/runbooks/server-setup.md` when implementation starts.
