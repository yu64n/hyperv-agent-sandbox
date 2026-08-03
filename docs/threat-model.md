# Threat model

The agent, sandbox OS, containers, and sandbox root are untrusted. The router and host remain trusted. The sandbox LAN uses a Hyper-V private switch, which has no management-OS NIC; do not replace it with an internal switch. Controls prevent direct internet forwarding, access to the host or household LAN, external DNS, and IPv6 bypass. Squid permits named HTTP(S) destinations only; this is an egress reduction control, not protection against malicious content on an allowed domain. Keep management SSH restricted at the external network perimeter and inspect proxy logs.
