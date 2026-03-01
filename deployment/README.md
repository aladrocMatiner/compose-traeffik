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
make deployment-project project=traefik-keycloak target=qemu os=ubuntu
make deployment-project project=traefik-observability target=qemu os=ubuntu
make deployment-project project=traefik-wikijs target=qemu os=ubuntu
make deployment-project project=traefik-semaphoreui target=qemu os=ubuntu
make deployment-project project=traefik-rocketchat target=qemu os=ubuntu
```

## Estado Actual De Deployments

```text
 Id   Name                           State
----------------------------------------------
 33   traefik-stepca-ubuntu          running
 34   traefik-keycloak-ubuntu        running
 35   traefik-observability-ubuntu   running
 36   traefik-wikijs-ubuntu          running
 37   traefik-semaphoreui-ubuntu     running
 38   traefik-rocketchat-ubuntu      running
```
