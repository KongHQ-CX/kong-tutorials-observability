# Kong Tutorials - Observability

Observability reference material for the Kong tutorials chapter "Observability".

## USAGE

To get running, you need to run the "base script" from the root of this repository.

Run it like so:

```sh
./initial-setup.sh [ingress-domain-name]
```

For example:

```sh
./initial-setup.sh kubernetes.mydomain.local
```

This sets up each Ingress object for access from your local network, via the default ingress controlled in your Kubernetes cluster.

After this, follow the same installation guides as the video tutorial from Kong.
