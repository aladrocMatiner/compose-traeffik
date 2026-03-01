# Deployment

## Deploy En QEMU

Prerequisitos:

- `terraform`
- `ansible-playbook`
- conectividad libvirt local (`qemu:///system`)

Listado de proyectos disponibles:

```bash
make deployment-project-list
```

Orden recomendado de despliegue en QEMU:

```bash
make deployment-project project=traefik-stepca target=qemu os=ubuntu
make deployment-project project=traefik-dns-bind target=qemu os=ubuntu
make deployment-project project=traefik-keycloak target=qemu os=ubuntu
make deployment-project project=traefik-observability target=qemu os=ubuntu
make deployment-project project=traefik-wikijs target=qemu os=ubuntu
make deployment-project project=traefik-semaphoreui target=qemu os=ubuntu
make deployment-project project=traefik-rocketchat target=qemu os=ubuntu
make deployment-project project=traefik-gitlab target=qemu os=ubuntu
```

Notas para `traefik-dns-bind`:

- BIND expone DNS directamente por `53/udp` y `53/tcp` (no pasa por Traefik).
- Traefik solo se usa para endpoints HTTP(S) del proyecto (por ejemplo, dashboard).
