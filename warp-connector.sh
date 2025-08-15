#!/bin/bash

echo -e "\nGenerating..."

curl -sSL https://pkg.cloudflareclient.com/pubkey.gpg \
  | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg \
  && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" \
  | tee /etc/apt/sources.list.d/cloudflare-client.list \
  && apt update -y \
  && apt install -y cloudflare-warp

wget -O /tmp/bore.tar.gz $(curl -s https://api.github.com/repos/ekzhang/bore/releases/latest | jq -r '.assets[] | select(.name | test("bore-v.*-x86_64-unknown-linux-musl.tar.gz")) | .browser_download_url')
tar -xf /tmp/bore.tar.gz -C /usr/bin/

dbus-daemon --system
/bin/warp-svc &
sleep 5s
warp-cli --accept-tos connector new "$1"

mkdir -p /tmp/wg0

cat > /tmp/wg0/wg0.conf << EOL
[Interface]
PrivateKey = $(jq -r .secret_key < /var/lib/cloudflare-warp/reg.json)
Address = $(jq -r .interface.v6 < /var/lib/cloudflare-warp/conf.json)/64
Address = $(jq -r .interface.v4 < /var/lib/cloudflare-warp/conf.json)/12

[Peer]
PublicKey = $(jq -r .public_key < /var/lib/cloudflare-warp/conf.json)
AllowedIPs = 0.0.0.0/0,::/0
Endpoint = $(jq -r .endpoints[0].v4 < /var/lib/cloudflare-warp/conf.json),$(jq -r .endpoints[1].v4 < /var/lib/cloudflare-warp/conf.json),$(jq -r .endpoints[2].v4 < /var/lib/cloudflare-warp/conf.json),$(jq -r .endpoints[3].v4 < /var/lib/cloudflare-warp/conf.json),$(jq -r .endpoints[0].v6 < /var/lib/cloudflare-warp/conf.json),$(jq -r .endpoints[1].v6 < /var/lib/cloudflare-warp/conf.json),$(jq -r .endpoints[2].v6 < /var/lib/cloudflare-warp/conf.json),$(jq -r .endpoints[3].v6 < /var/lib/cloudflare-warp/conf.json)
EOL

screen -dmS python sh -c 'python3 -m http.server 80 --directory /tmp/wg0'
screen -dmS bore sh -c 'bore local 80 --to bore.pub 2>&1 | tee /tmp/bore.log'
sleep 5s

ADDRESS=$(grep -oP "listening at \K[a-zA-Z0-9.-]+:[0-9]+" /tmp/bore.log | head -n 1)
URL="http://$(dig +short "${ADDRESS%:*}")":${ADDRESS##*:}/wg0.conf

echo -e "\n$URL\n"
