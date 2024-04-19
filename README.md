# Docker-NordVPN-Client-DoH
This Docker image simplifies the setup of a network container, directing traffic through NordVPN's VPN while securing DNS encryption via Cloudflare's DoH.

# Whai is it?
This container image facilitates routing connections from other containers through OpenVPN to NordVPN's service. DNS resolution is directed through a crypto-proxy to Cloudflare using DNS over HTTPS (DoH), ensuring encryption of DNS requests and bypassing those of the host, thereby offering automatic DNS query protection by the container.

Moreover, the container includes a kill switch that halts connectivity should the VPN connection fail. It also enables access to connected containers via specified subnets.

It originates from the integration of these projects:
* from [Ben Lobaugh](https://github.com/blobaugh)'s work in the [Docker OpenVPN Client](https://github.com/blobaugh/docker-openvpn-client.git) project
* from [Wyatt Gill](https://github.com/wfg)'s work in the [Docker OpenVPN Client](https://github.com/wfg/docker-openvpn-client.git) project
* from my other project [Docker Cloudflare DoH](https://github.com/paolo-hub/Docker-Cloudflare-DoH.git)

## 🙊 Psst... the unspoken truth
This image is designed to utilize the NordVPN service but can easily be reconstructed for any other VPN service.
