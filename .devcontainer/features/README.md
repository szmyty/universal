# docker-proxy

Adds a helper script that configures Docker to work behind an HTTP/HTTPS proxy.
Proxy values can be provided via feature options. If an option is left empty or
set to `none` the proxy will be disabled.

## Example Usage

```json
"./features/docker-proxy": {
  "http_proxy": "http://proxy.example:8080",
  "https_proxy": "http://proxy.example:8080",
  "no_proxy": "localhost,127.0.0.1",
  "docker_dns": "8.8.4.4"
}
```

## Options

| Option Id | Description | Type | Default |
|-----------|-------------|------|---------|
| `http_proxy` | HTTP proxy URL or `none` to disable | string | `` |
| `https_proxy` | HTTPS proxy URL or `none` to disable | string | `` |
| `no_proxy` | Comma-separated hosts excluded from proxy | string | `` |
| `docker_dns` | DNS server for Docker daemon | string | `8.8.8.8` |
| `insecure_registries` | Comma separated list of insecure registries | string | `` |
