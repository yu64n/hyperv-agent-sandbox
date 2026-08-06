# Repository guidelines

## Scope

These instructions apply to the entire repository.

## Development environment

- Run development tools, linters, tests, and repository helper scripts through the
  Nix development shell. Prefer one-shot commands such as
  `nix develop -c make check` and `nix develop -c bash -lc '<command>'` so that
  every contributor uses the tool versions declared by `flake.nix` and
  `flake.lock`.
- Do not install or invoke host copies of tools supplied by the development shell.
- PowerShell commands that manage Hyper-V are the exception: run them on the
  Windows Hyper-V host (normally via the `make hyperv` and `make destroy`
  targets from WSL) because they require host-only Hyper-V APIs.

## Change guidelines

- Keep the PowerShell, shell, cloud-init, and Ansible automation idempotent.
- Treat the router VM as the trust boundary. Do not weaken the default-deny
  forwarding policy, bypass the Squid allowlist, intercept TLS, or bridge the
  external switch to a trusted LAN.
- Never commit credentials, private keys, generated seed images, or local
  `config/sandbox.env` values. Keep example values obviously non-secret.
- Update the README and relevant files under `docs/` whenever behavior,
  prerequisites, security assumptions, or operator workflows change.

## Validation

- Run `nix develop -c make check` for every change.
- Run focused checks for the files you changed through `nix develop`, including
  shell syntax checks or Ansible syntax checks where appropriate.
- Run `nix develop -c make test` only when the Router and Sandbox VMs are
  available. Run Hyper-V lifecycle checks only on a Windows host where creating
  and destroying disposable VMs is safe.
- Run `nix develop -c git diff --check` before committing.
- Record every check in the pull request. Clearly mark checks that could not run
  and explain any missing Hyper-V or network dependency.
