# ECMP-Demo

Run `vagrant up` and add a route for the AnyCast-Address `10.0.0.50` to the leaf box:

```bash
ip route add 10.0.0.50/32 via 10.255.1.148
```

Test with curl:

```bash
curl http://10.0.0.50:8080
```

![Network topology](./topology.svg)
