# Mininet in Docker (Rocky Linux)

A modern, RHEL-flavored Docker image for [Mininet](http://mininet.org/).

## Highlights

- Mininet 2.3.1b4, OpenvSwitch 3.1.0 and OpenFlow 1.0.
- Based on Rocky Linux 8, a RHEL clone.
- Systemd inside, for better support of OpenvSwitch.

## Usage

Podman is preferred as it has better support for Systemd. 

```bash
podman build -t mininet:rocky-8 .

podman run -d --privileged \
           --systemd true \
           -v /lib/modules:/lib/modules:ro \
           mininet:rocky-8 /usr/sbin/init

podman exec -it <container_id> /bin/bash
```

Then you can run Mininet commands as usual. 

```bash
mn --test pingall
```

> **Note:** We have built-in support for Systemd in this image and it has to be PID 1 in the container. So DO NOT alter the entrypoint. Use `exec` instead. 

## Customization

It should be easy to extend the Dockerfile to support Rocky Linux 9 / Fedora 32+. 