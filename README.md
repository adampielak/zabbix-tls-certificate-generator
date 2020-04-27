# Zabbix TLS Certificate Generator

## Build
`sh build.sh`

## Generate root CA certificate
`sh generate_root.sh`

## Generate intermediate CA certificate (if used)
`sh generate_intermediate.sh`

## Generate certificates

### Server certificate
#### With intermediate CA
`sh generate_cert.sh generate_cert.sh --server --inter --name <host_name>`

#### Without intermediate CA
`sh generate_cert.sh generate_cert.sh --server --name <host_name>`

### Agent certificate
#### With intermediate CA
`sh generate_cert.sh generate_cert.sh --inter --name <host_name>`

#### Without intermediate CA
`sh generate_cert.sh generate_cert.sh --name <host_name>`

## Collect enc files
enc files will be created as tar files under the enc directory as `enc/enc_<host>.tar`
