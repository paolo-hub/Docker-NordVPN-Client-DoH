# Docker-NordVPN-Client-DoH
This Docker image simplifies the setup of a network container, directing traffic through NordVPN's VPN while securing DNS encryption via Cloudflare's DoH.

![alt text](https://badgen.net/badge/release/v.1.0/green?) ![alt text](https://badgen.net/badge/platform/Docker/blue?) ![alt text](https://badgen.net/badge/license/MIT/yellow?)

## Whai is it?
This container image facilitates routing connections from other containers through OpenVPN to NordVPN's service. DNS resolution is directed through a crypto-proxy to Cloudflare using DNS over HTTPS (DoH), ensuring encryption of DNS requests and bypassing those of the host, thereby offering automatic DNS query protection by the container.

Moreover, the container includes a kill switch that halts connectivity should the VPN connection fail. It also enables access to connected containers via specified subnets.

It originates from the integration of these projects:
  * from [Ben Lobaugh](https://github.com/blobaugh)'s work in the [Docker OpenVPN Client](https://github.com/blobaugh/docker-openvpn-client.git) project
  * from [Wyatt Gill](https://github.com/wfg)'s work in the [Docker OpenVPN Client](https://github.com/wfg/docker-openvpn-client.git) project
  * from my other project [Docker Cloudflare DoH](https://github.com/paolo-hub/Docker-Cloudflare-DoH.git)

### 🙊 Psst... the unspoken truth
This image is designed to utilize the NordVPN service but can easily be reconstructed for any other VPN service.

## How to Use It

### Supported Platforms

The image is available on [Docker Hub page](https://hub.docker.com/repository/docker/paolo83/nordvpn-client-doh)

The supported platforms are:
  * linux/amd64
  * linux/arm/v7
  * linux/arm64

### Deploy the container
To run the container, you can use the following Docker Compose file:
```yaml
version: "3.9"

services:
  nordvpn_client_doh: 
    image: paolo83/nordvpn-client-doh:latest  
    container_name: nordvpn-client-doh
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    environment:
      - ALLOWED_SUBNETS=<your local net>
      - VPN_SERVICE=NordVPN
      - VPN_SERVER=<name of the NordVPN server>
      - VPN_PROTOCOL=<UDP or TCP>
      - VPN_USER=<your user for manual connection>
      - VPN_PASS=<your token for manual connection>
      - KILL_SWITCH=<on or off>
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
      # List of Ports
      - <host_port>:<contaier_port>
```
### Environment variables

|     Variable     |    Requirments  |  Description   |
| ---------------- | --------------- | -------------- |
| ALLOWED_SUBNETS  | Optional/Require KILL_SWITCH 'on'| A list of one or more comma-separated subnets (e.g. 192.168.100.0/24,192.168.150.0/24) to allow outside of the VPN tunnel. |
| VPN_SERVICE      | Required        | NordVPN, this variable has been set for future integration with other VPN services                                         |
| VPN_SERVER       | Required        | The VPN server name, for example, is it250. You can find this name on servers recommended by NordVPN (https://nordvpn.com/it/servers/tools/)|
| VPN_PROTOCOL     | Required        | Choose either UDP or TCP based on your preference             |
| VPN_USER         | Required        | Your NordVPN username for manual connection              |
| VPN_PASS         | Required        | Your NordVPN token for manual connection             |
| KILL_SWITCH      | Optional        | "Set to 'on' or 'off', default is 'off'              |


