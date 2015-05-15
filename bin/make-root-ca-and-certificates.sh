#!/bin/bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${__dir}/colors.sh

function show_help() {
  echo -e "
Usage: ./make-root-ca-and-certificates.sh [OPTIONS]

Create a root ca and then use it to sign certificates for both [hostname] and
*.[hostname]. The root ca and the certificates will then be stored in [ca-dir]
and [certificates-dir] respectively. If the certificates already exist in the
specified directories, this script will exit cleanly.

  --ca-dir=[]             Absolute path to CA certificates directory
  --certificates-dir=[]   Absolute path to server certificates directory
  -f, --force             Force creation of certificate authority and self-signed
                          certificates even if they already exist.
  -h, --help              Show this page
  --hostname=[]           Fully qualified domain name of certificates.
  "
}

function cleanup() {
  printf "Cleaning up...\n"
  (rm -r .tmp) >/dev/null 2>/dev/null
}

trap "echo -e \"\n\n${red}Exiting...${reset}\n\"; cleanup; exit;" SIGINT SIGTERM
echo

# Reset all variables that might be set
hostname=
ca_dir=
certificates_dir=
force=
while :; do
  case $1 in
    --ca-dir)
      if [ -n "$2" ]; then
          ca_dir=$2
          shift 2
          continue
      else
          printf "${red}ERROR: '--ca-dir' requires a non-empty option argument.${reset}\n" >&2
          exit 1
      fi
      ;;
    --ca-dir=?*)
      ca_dir=${1#*=}    # Delete everything up to "=" and assign the remainder.
      ;;
    --ca-dir=)          # Handle the case of an empty --ca-dir=
      printf "${red}ERROR: '--ca-dir' requires a non-empty option argument.${reset}\n" >&2
      exit 1
      ;;
    --certificates-dir)
      if [ -n "$2" ]; then
          certificates_dir=$2
          shift 2
          continue
      else
          printf "${red}ERROR: '--certificates-dir' requires a non-empty option argument.${reset}\n" >&2
          exit 1
      fi
      ;;
    --certificates-dir=?*)
      certificates_dir=${1#*=}    # Delete everything up to "=" and assign the remainder.
      ;;
    --certificates-dir=)          # Handle the case of an empty --certificates-dir=
      printf "${red}ERROR: '--certificates-dir' requires a non-empty option argument.${reset}\n" >&2
      exit 1
      ;;
    -f|-\?|--force)
      force=true
      ;;
    -h|-\?|--help)
      show_help
      exit 0
      ;;
    --hostname)
      if [ -n "$2" ]; then
          hostname=$2
          shift 2
          continue
      else
          printf "${red}ERROR: '--hostname' requires a non-empty option argument.${reset}\n" >&2
          exit 1
      fi
      ;;
    --hostname=?*)
      hostname=${1#*=}    # Delete everything up to "=" and assign the remainder.
      ;;
    --hostname=)          # Handle the case of an empty --hostname=
      printf "${red}ERROR: '--hostname' requires a non-empty option argument.${reset}\n" >&2
      exit 1
      ;;
    --)                   # End of all options.
      shift
      break
      ;;
    -?*)
      printf "${yellow}WARN: Unknown option (ignored): %s${reset}\n" "$1" >&2
      ;;
    *)                    # Default case: If no more options then break out of the loop.
      break
  esac
  shift
done

if [ -z "${ca_dir}" ]; then
    printf "${red}ERROR: option '--ca-dir PATH' not given. See --help.${reset}\n" >&2
    exit 1
fi
if [ -z "${certificates_dir}" ]; then
    printf "${red}ERROR: option '--certificates-dir PATH' not given. See --help.${reset}\n" >&2
    exit 1
fi
if [ -z "$hostname" ]; then
    printf "${red}ERROR: option '--hostname FILE' not given. See --help.${reset}\n" >&2
    exit 1
fi

#########################################
# Generating a self-signed Certificates #
#########################################
if [ -f "${ca_dir}/waffle-root-ca.crt" ] &&
   [ -f "${certificates_dir}/${hostname}.crt" ] &&
   [ -f "${certificates_dir}/${hostname}.key" ] &&
   [ -f "${certificates_dir}/*.${hostname}.crt" ] &&
   [ -f "${certificates_dir}/*.${hostname}.key" ] &&
   [ ! $force ] ;
then
  printf "Certificates already exists, skipping creating a new ones.\n"
else
  printf "Generating self-signed certificates...\n${grey}"

  mkdir -p .tmp/certs/{ca,server,tmp}

  # Create your very own Root Certificate Authority
  openssl genrsa \
    -out .tmp/certs/ca/waffle-root-ca.key \
    2048

  # Self-sign your Root Certificate Authority
  # Since this is private, the details can be as bogus as you like
  # -days 7670  --  21 years
  openssl req \
    -x509 \
    -new \
    -nodes \
    -key .tmp/certs/ca/waffle-root-ca.key \
    -days 7670 \
    -out .tmp/certs/ca/waffle-root-ca.crt \
    -subj "/C=US/ST=Colorado/L=Boulder/O=Waffle Ironing Authority Inc/CN=waffle-ironing-ca.com"

  # Create a Device Certificate for each domain,
  # such as example.com, *.example.com, awesome.example.com
  # NOTE: You MUST match CN to the domain name or ip address you want to use
  openssl genrsa \
    -out .tmp/certs/server/${hostname}.key \
    2048
  openssl genrsa \
    -out .tmp/certs/server/*.${hostname}.key \
    2048

  # Create a request from your Device, which your Root CA will sign
  openssl req -new \
    -key .tmp/certs/server/${hostname}.key \
    -out .tmp/certs/tmp/${hostname}.csr \
    -subj "/C=US/ST=Colorado/L=Boulder/O=Waffle Takeout Inc/CN=${hostname}"
  openssl req -new \
    -key .tmp/certs/server/*.${hostname}.key \
    -out .tmp/certs/tmp/*.${hostname}.csr \
    -subj "/C=US/ST=Colorado/L=Boulder/O=Waffle Takeout Inc/CN=*.${hostname}"

  # Sign the request from Device with your Root CA
  # -CAserial .tmp/certs/ca/waffle-root-ca.srl
  # -days 7304  --  20 years
  openssl x509 \
    -req -in .tmp/certs/tmp/${hostname}.csr \
    -CA .tmp/certs/ca/waffle-root-ca.crt \
    -CAkey .tmp/certs/ca/waffle-root-ca.key \
    -CAcreateserial \
    -out .tmp/certs/server/${hostname}.crt \
    -days 7304
  openssl x509 \
    -req -in .tmp/certs/tmp/*.${hostname}.csr \
    -CA .tmp/certs/ca/waffle-root-ca.crt \
    -CAkey .tmp/certs/ca/waffle-root-ca.key \
    -CAcreateserial \
    -out .tmp/certs/server/*.${hostname}.crt \
    -days 7304

  cp .tmp/certs/ca/waffle-root-ca.crt ${ca_dir}
  cp .tmp/certs/server/${hostname}.crt ${certificates_dir}
  cp .tmp/certs/server/${hostname}.key ${certificates_dir}
  cp .tmp/certs/server/*.${hostname}.crt ${certificates_dir}
  cp .tmp/certs/server/*.${hostname}.key ${certificates_dir}

  printf "${reset}"
fi

cleanup
printf "Done!\n\n"
