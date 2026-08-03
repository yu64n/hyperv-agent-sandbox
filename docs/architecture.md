# Architecture

The Windows host owns Hyper-V policy. The Debian router has WAN and private-switch LAN NICs; the Ubuntu sandbox has only the LAN NIC. A Hyper-V private switch deliberately provides no management-OS adapter, so all sandbox management crosses the router trust boundary. Configuration flows from WSL through PowerShell and Ansible. cloud-init seed media is bootstrap-only and separate from each distribution's bootable installer ISO, while repeatable guest state belongs to Ansible.
