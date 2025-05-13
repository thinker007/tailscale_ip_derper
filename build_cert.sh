#!/bin/bash
# Usage: ./script.sh example.com|192.168.1.1 /path/to/certificates /path/to/config.conf

CERT_HOST=$1
CERT_DIR=$2
CONF_FILE=$3

# 检测是否为IP地址
if [[ $CERT_HOST =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  # 是IP地址
  ALT_NAME="IP.1 = $CERT_HOST"
else
  # 是域名
  ALT_NAME="DNS.1 = $CERT_HOST"
fi

echo "[req]
default_bits  = 2048
distinguished_name = req_distinguished_name
req_extensions = req_ext
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
countryName = XX
stateOrProvinceName = N/A
localityName = N/A
organizationName = Self-signed certificate
commonName = $CERT_HOST
[req_ext]
subjectAltName = @alt_names
[v3_req]
subjectAltName = @alt_names
[alt_names]
$ALT_NAME
" > "$CONF_FILE"

mkdir -p "$CERT_DIR"
openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout "$CERT_DIR/$CERT_HOST.key" -out "$CERT_DIR/$CERT_HOST.crt" -config "$CONF_FILE"

echo "证书已生成:"
echo "私钥: $CERT_DIR/$CERT_HOST.key"
echo "证书: $CERT_DIR/$CERT_HOST.crt"
