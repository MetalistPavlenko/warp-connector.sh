# Generate Cloudflare WARP Config for WireGuard
This bash script generates a WARP Connector tunnel for WireGuard.

1. Go to: https://terminator.aeza.net
2. Select: **`debian`**
3. Insert the command:
```bash
bash <(wget -qO- https://raw.githubusercontent.com/MetalistPavlenko/warp-connector.sh/main/warp-connector.sh)
```
4. After the config is generated, download the file from the link and import it into WireGuard.
