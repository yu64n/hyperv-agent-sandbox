# Hyper-V Agent Sandbox

Disposable Ubuntu coding VM isolated behind a Debian router VM. The router is the trust boundary: nftables denies forwarding by default and Squid provides the only HTTP(S) egress through a domain allowlist. TLS is not intercepted.

## Quick start

1. Copy `config/sandbox.env.example` to `config/sandbox.env` and replace both cloud-init SSH placeholders.
2. Download separate Debian and Ubuntu installer ISOs, set their Windows-accessible paths in `ROUTER_INSTALLER_ISO` and `SANDBOX_INSTALLER_ISO`, and create the external Hyper-V switch on the intended WAN adapter. Never bridge it to a trusted LAN.
3. Run `nix develop`, `make seeds`, and `make hyperv` from WSL. The generated ISOs under `build/seeds/` contain only NoCloud cloud-init data and are not bootable installers. `make hyperv` attaches each guest's installer and seed as separate DVD drives and selects the installer for first boot. Complete both installations, boot the installed systems, then run `make apply`.
4. Connect with `ssh -J sandbox-admin@10.20.0.1 agent@10.20.0.10`. Forward a localhost-only development server with `-L 3000:localhost:3000`.
5. Run `make test`; destroy the disposable environment with `make destroy`.

Do not use SSH agent forwarding or Hyper-V shared folders. Move work with a Git bundle (`git bundle create work.bundle --all`) or `scp`/`rsync`. Use a dedicated 1Password service account vault and a repository-scoped, short-lived GitHub token. Review `docs/threat-model.md` before use.

`Sandbox-LAN` is a Hyper-V private switch: the management OS has no adapter on the untrusted layer-2 segment. Management access must traverse the router; do not change it to an internal switch.
