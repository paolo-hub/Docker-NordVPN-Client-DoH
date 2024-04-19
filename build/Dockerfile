# Use Alpine Linux Image
FROM alpine:latest

# Install openvpn dnscrypt-proxy e dnscrypt-proxy-openrc
RUN apk add --no-cache \
    bash \
    bind-tools \
    iptables \
    ip6tables \
    curl \
    openrc \
    dnscrypt-proxy \
    dnscrypt-proxy-openrc \
    openvpn

# Copy configuration file
COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
COPY servers /servers
COPY entry.sh /entry.sh
COPY . /usr/local/bin
COPY kill_switch.sh /usr/local/bin/kill_switch.sh

# Make the scripts executable 
RUN chmod +x /entry.sh
RUN chmod +x /usr/local/bin/kill_switch.sh

# Default Environment
ENV KILL_SWITCH=on

# Expose port 53 for DNS service
EXPOSE 53/udp 53/tcp

# Set the init command
CMD ["/entry.sh"]
