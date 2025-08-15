# Generate CloudFlare Zero Trust Tunnel Config for WireGuard
This bash script generates a CloudFlare Zero Trust Tunnel for WireGuard.

1. Go to: https://terminator.aeza.net
2. Select: **`debian`**
3. Insert the command:
```bash
wget -O /tmp/warp-connector.sh https://raw.githubusercontent.com/MetalistPavlenko/warp-connector.sh/main/warp-connector.sh
```
4. Insert the command:
```bash
bash /tmp/warp-connector.sh <token>
```
5. After the config is generated, download the file from the link and import it into WireGuard.
