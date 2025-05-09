
To generate the private keys to be able to run the server over HTTPS so devices can use their media devices

```sh
❯ openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes
```

To start the server, run the following command:

```sh
> python3 http-server.py
```

And on any device on the same network, open the following URL:

[https://<your-machine-ip>:4443](https://<your-machine-ip>:4443)
