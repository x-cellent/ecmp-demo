# ECMP-Demo

Run `vagrant up` and add a route for the AnyCast-Address to the Vagrant-Bridge:

```bash
ip route add 10.0.0.50/32 via 10.255.1.148
```

Test with curl:
```bash
curl http://10.0.0.50:8080
```
