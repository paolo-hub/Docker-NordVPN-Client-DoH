#!/usr/bin/env bash

######################
# SCRIPT CONFIGURATION
######################

set -o errexit
set -o nounset
set -o pipefail

cleanup() {
    kill TERM "$openvpn_pid"
    exit 0
}

##########################
# CONFIGURE OPENVPN CLIENT
#########################

# VPN service folder
VPN_SERVICE_FOLDER="/servers/$VPN_SERVICE"
# VPN service configuration file
VPN_OVPN="$VPN_SERVICE_FOLDER/$VPN_PROTOCOL/$VPN_SERVER.ovpn"

# VPN user/pass file
VPN_AUTH_FILE="/servers/secret.key"

# Extra params passed to openvpn client. See https://community.openvpn.net/openvpn/wiki/Openvpn23ManPage
openvpn_opt=(
    "--ping" "15"
)


# The following are from the .env file
# VPN_SERVICE
# VPN_SERVER
# VPN_PROTOCOL
# VPN_USER
# VPN_PASS
# KILL_SWITCH
# ALLOWED_SUBNETS

###########################
# END OBENVPN CONFIGURATION
###########################

#######################
# SETUP THE CONNECTTION
#######################

# Setup the user/pass login file
rm -f $VPN_AUTH_FILE
touch $VPN_AUTH_FILE

echo $VPN_USER >> $VPN_AUTH_FILE
echo $VPN_PASS >> $VPN_AUTH_FILE

# Debugging
echo "
-- VPN Configuration ---
"

echo "OpenVPN configuration file: $VPN_OVPN"

echo "VPN auth file: $VPN_AUTH_FILE"


# Verify the vpn config file exists
if [ ! -f "$VPN_OVPN" ]; then
	echo "Unable to find VPN server: $VPN_SERVER"
	exit
fi


# Kill Switch and Allowable Subnets

if [ ! -f "/usr/local/bin/kill_switch.sh" ]; then
        echo "Unable to find kill switch script"
        exit
fi

is_enabled() {
    [[ ${1,,} =~ ^(true|t|yes|y|1|on|enable|enabled)$ ]]
}

if is_enabled "$KILL_SWITCH"; then
    echo "Kill switch enabled"
    openvpn_opt+=("--script-security" "3" "--route-up" "/usr/local/bin/kill_switch.sh $ALLOWED_SUBNETS")
fi

# Start Cloudfale DoH DNS service
echo "
--- Starting Cloudflare DoH ---
"
dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml &
sleep 20
echo "Hard update DNS Server with localhost 127.0.0.1"
echo 'nameserver 127.0.0.1' > /etc/resolv.conf


# Kick off the connection
echo "
--- Starting VPN Client ---
"

openvpn_opt+=("--config" "$VPN_OVPN" "--auth-user-pass" "$VPN_AUTH_FILE")
echo "Starting  Connection with the following parameters:"
echo "${openvpn_opt[@]}"

# See https://community.openvpn.net/openvpn/wiki/Openvpn23ManPage
openvpn "${openvpn_opt[@]}" &
openvpn_pid=$!

trap cleanup TERM

wait $openvpn_pid
