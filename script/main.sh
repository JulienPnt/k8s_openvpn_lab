#!/bin/bash

DEFAULT_VPN_IP="192.168.1.42"
DEFAULT_VPN_PORT="1194"

_echo() {
  local flag=${1}
  shift
  echo -e "[$(date)] ${flag}: ${@}"
}

echo_dbg() {
  local flag="DBG"
  _echo ${flag} ${@}
}

echo_err() {
  local flag="ERR"
  _echo ${flag} ${@}
}

usage() {
  echo_dbg "$(basename ${0}) <SN> <VPN-IP> (optionnal) <VPN-PORT> (optionnal)"
  echo_dbg "SN, only used for pretty stuff purpose"
  echo_dbg "VPN-IP, if not set default: ${DEFAULT_VPN_IP}"
  echo_dbg "VPN-PORT, if not set default: ${DEFAULT_VPN_PORT}"
  echo_dbg "DEFAULT VALUES maybe changed at the begining of the script"
}

manage_usage() {
  if [[ ${#} -eq 0 ]]; then
    echo_err "An SN must be supplied !"
    return 1
  fi
  SN=${1}
  if [[ ${#} -eq 1 ]]; then
    echo_dbg "Default VPN value are going to be applied"
    VPN_IP=${DEFAULT_VPN_IP}
    VPN_PORT=${DEFAULT_VPN_PORT}
  elif [[ ${#} -eq 2 ]]; then
    echo_dbg "Default VPN PORT is going to be applied"
    VPN_IP=${2}
    VPN_PORT=${DEFAULT_VPN_PORT}
  elif [[ ${#} -eq 3 ]]; then
    echo_dbg "Custom VPN PORT & IP are going to be applied"
    VPN_IP=${2}
    VPN_PORT=${3}
  else
    echo_err "Too much args in input"
    return 2
  fi
  echo_dbg "Check config below:"
  echo_dbg "SN: ${SN}, VPN-IP: ${VPN_IP}, VPN-PORT: ${VPN_PORT}"
  return 0
}

check_openvpn_get_ip_addr() {
  ip tap | grep tun0
  return ${?}
}

launch_openvpn_client() {
  local vpn_ip=${1}
  local vpn_port=${2}
  openvpn --config /etc/openvpn/client.conf --remote ${vpn_ip} ${vpn_port} >/dev/null &
  sleep 5
  check_openvpn_get_ip_addr
}

keep_client_open() {
  sleep infinity
}

main() {
  manage_usage ${@}
  if [[ ${?} -ne 0 ]]; then
    echo_err "Failed to usage: ${?}"
    usage
    exit 1
  fi
  launch_openvpn_client
  if [[ ${?} -ne 0 ]]; then
    echo_err "Failed to open vpn tunnel"
    exit 2
  fi
  keep_client_open
}

main ${@}
