# Architecture

The Windows host owns Hyper-V policy. The Debian router has WAN and isolated LAN NICs; the Ubuntu sandbox has only the LAN NIC. Configuration flows from WSL through PowerShell and Ansible. cloud-init is bootstrap-only, while repeatable guest state belongs to Ansible.
