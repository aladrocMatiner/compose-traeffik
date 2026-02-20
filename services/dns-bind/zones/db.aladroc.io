$TTL 1h
@   IN  SOA ns1.aladroc.io. hostmaster.aladroc.io. (
        2026022021 ; serial
        1h ; refresh
        15m ; retry
        1w ; expire
        1h ; minimum
)

@   IN  NS  ns1.aladroc.io.
ns1 IN  A   127.0.10.254
bind IN  A  127.0.10.254
whoami IN  A   127.0.10.1
traefik IN  A   127.0.10.2
stepca IN  A   127.0.10.3
dns IN  A   127.0.10.4
webui IN  A   127.0.10.5
guacamole IN  A   10.64.70.15
haproxy IN  A   10.64.70.10
bastion-70 IN  A   10.64.70.31
bastion-w11-70 IN  A   10.64.70.30
