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
| ALLOWED_SUBNETS  | Optional / Require KILL_SWITCH 'on'| A list of one or more comma-separated subnets (e.g. 192.168.100.0/24,192.168.150.0/24) to allow outside of the VPN tunnel. |
| VPN_SERVICE      | Required        | NordVPN, this variable has been set for future integration with other VPN services                                         |
| VPN_SERVER       | Required        | The VPN server name, for example, is it250. You can find this name on servers recommended by NordVPN (https://nordvpn.com/it/servers/tools/)|
| VPN_PROTOCOL     | Required        | Choose either UDP or TCP based on your preference             |
| VPN_USER         | Required        | Your NordVPN username for manual connection              |
| VPN_PASS         | Required        | Your NordVPN token for manual connection             |
| KILL_SWITCH      | Optional        | Set to 'on' or 'off', default is 'off'              |

### Where to find NordVPN credentials
The NordVPN credentials for manual connection can be retrieved from the personal page of the service, under the section "Get service credentials or an access token."

### Interacting with other containers
After launching your nordvpn-client-doh container, you can enable other containers to utilize its VPN tunnel by leveraging its network stack. How you achieve this depends on how your container is set up:
1. If your container is created using the same Compose YAML file as nordvpn-client-doh, `include network_mode: 'service:nordvpn-client-doh'` in the container's service definition.
2. If your container is created using a different Compose YAML file than nordvpn-client-doh, `include 'network_mode: container:nordvpn-client-doh'` in the container's service definition.
3. If you're using docker run, add `--network=container:nordvpn-client-doh` as an option.

### Managing ports for connected containers
If you're trying to access a port from a connected container, it's better to expose that port on the nordvpn-client-doh container instead. Here's how you can do it:

For docker run, use `-p <host_port>:<container_port>`.
If you're using docker-compose, add this snippet to the nordvpn-client-doh service definition in your Compose file:

```yaml
ports:
  - <host_port>:<container_port>
```

Remember to replace `host_port` and `container_port` with the corresponding port numbers used by your connected container.

## Build Your Own Image
If preferred, you can create the Docker image locally. Follow these steps:

1. Clone the Git repository to your local machine:
``` bash
git clone https://github.com/paolo-hub/Docker-NordVPN-Client-DoH.git
```
2. Navigate to the cloned repository directory:
``` bash
cd Docker-NordVPN-Client-DoH/build
```
3. Next, build the Docker image using the provided Dockerfile:
```bash
docker build -t paolo83/nordvpn-client-doh:latest -f Dockerfile .
```

### How to create an image for a different VPN service
If you want to create the image to use a VPN service other than NordVPN, you can add its respective `*.ovpn` certificates and recreate the image. To do this, follow these steps:

1. Clone the Git repository to your local machine:
```bash
git clone https://github.com/paolo-hub/Docker-NordVPN-Client-DoH.git
```
2. Navigate to the cloned repository directory:
```bash
cd Docker-NordVPN-Client-DoH/build
```
In this folder, you will find the following items:
  * servers
  * Dockerfile
  * dnscrypt-proxy.toml
  * entry.sh
  * kill_switch.sh

Inside the `servers` folder, there is a subfolder for the `NordVPN` service, which contains two folders: `TCP` and `UDP`. To add a new service, for example, `MyVPN`, add a `MyVPN` folder inside the `servers` folder and create the `TCP` and `UDP` folders within it. Then, add the `*.ovpn` certificates into their respective `TCP` and `UDP` folders.
Remember:
1. The environment variable `VPN_SERVICE` should be set as follows:
```yaml
- VPN_SERVICE=MyVPN
```
2. The environment variable `VPN_SERVER` should contain the name of the certificate without the `.ovpn` extension.

3. All other settings should be adjusted accordingly. Access credentials should be obtained from your VPN service provider.

At this point, you can recreate the image:
```bash
docker build -t paolo83/myvpn-client-doh:latest -f Dockerfile .
```

## Testing
Once the container is up and running, you can perform connection tests to ensure everything is working properly.
1. You can check if the DNS server has been correctly received by running:

```bash
$ docker run --rm -it --network=container:nordvpn-client-doh alpine cat /etc/resolv.conf

nameserver 127.0.0.1
```
2. You can verify that the public IP address of the connection is different from your own network by checking the IPs assigned by NordVPN:
```bash
$ docker run --rm -it --network=container:nordvpn-client-doh alpine wget -qO - ifconfig.me

178.249.211.9 # This IP is one of NordVPN's servers.
```

You can also perform additional tests by leveraging a Ubuntu container launched with bash:

```bash
$ docker run -it --network="container:nordvpn-client-doh" ubuntu bash
```

3. Then, you can execute a server speed test, which can be useful for comparing performance between different servers:

```
$ apt update && apt install speedtest-cli -y && speedtest
```

4. You can verify the actual connection to Cloudflare and check for any DNS leaks using the script developed in the [macvk](https://github.com/macvk) GitHub project: [dnsleaktest](https://github.com/macvk/dnsleaktest)

```bash
# Install necessary packages
$ apt install curl
$ apt install iputils-ping

# Download the script
$ curl https://raw.githubusercontent.com/macvk/dnsleaktest/master/dnsleaktest.sh -o dnsleaktest.sh

# Make it executable
$ chmod +x dnsleaktest.sh

# Then run it
$ ./dnsleaktest.sh

# The test result is as follows
Your IP:
178.249.211.9 [Italy, AS212238 DataCamp Limited]
You use 2 DNS servers:
162.158.196.118 [Italy, AS13335 CloudFlare Inc.]
162.158.196.119 [Italy, AS13335 CloudFlare Inc.]
```

Here, you can see the NordVPN IP and the two Cloudflare DNS server IPs, indicating no leaks.
