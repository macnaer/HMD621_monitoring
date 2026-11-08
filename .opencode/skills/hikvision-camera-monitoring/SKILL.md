---
name: hikvision-camera-monitoring
description: Use when planning or implementing monitoring of Hikvision IP cameras, including ISAPI over HTTPS with digest authentication, alert stream events, RTSP and ONVIF stream checks, and firmware and credential hygiene. Planned for a later phase of the project.
---

# Hikvision camera monitoring

Status: planned for a later phase. Do not implement checks until the user approves the phase.

## Principles

- Use the vendor ISAPI over HTTPS with digest authentication. Confirm each endpoint against the camera firmware documentation before use.
- Change default credentials on every camera before adding it to monitoring. Never store camera passwords in the repository.
- Place cameras in a management VLAN. Allow monitoring access only from the monitoring host.
- Keep firmware updated. CVE-2021-36260 affects certain camera models and firmware versions.

## Candidate checks

| Check | Method | Notes |
|---|---|---|
| Reachability | ICMP and HTTPS | Basic availability |
| Device status | ISAPI device information endpoints | Endpoint names vary by model |
| Stream availability | RTSP or ONVIF | Check that the stream responds |
| Events | ISAPI alert stream | Motion, tamper, video loss, disk events |

## Before implementing

1. Ask the user for the camera models and firmware versions.
2. Confirm the endpoints with the camera documentation or a test request that the user approves.
3. Propose the check design and wait for approval.
