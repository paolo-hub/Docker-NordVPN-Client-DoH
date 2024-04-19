# Docker-NordVPN-Client-DoH
This Docker image simplifies the setup of a network container, directing traffic through NordVPN's VPN while securing DNS encryption via Cloudflare's DoH.

# Whai is it
This container image facilitates routing connections from other containers through OpenVPN to NordVPN's service. DNS resolution is directed through a crypto-proxy to Cloudflare using DNS over HTTPS (DoH), ensuring encryption of DNS requests and bypassing those of the host, thereby offering automatic DNS query protection by the container.

Moreover, the container includes a kill switch that halts connectivity should the VPN connection fail. It also enables access to connected containers via specified subnets.

It originates from the integration of these projects:
* a
* b
* c
