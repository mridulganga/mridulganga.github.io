---
title: "Simple systemd on Linux"
date: 2020-09-04T20:15:23+05:30
slug: ""
description: "A simple example for systemd"
keywords: []
draft: false
tags: ["tech","systemd","flask"]
math: false
toc: false
---

Below is a super simple guide to creating a systemd service on linux. Systemd is not yet supported on all the linux systems, but it's popular and easy to use.

## What is systemd?
systemd is a Linux initialization system and service manager that includes features like on-demand starting of daemons, mount and automount point maintenance, snapshot support, and processes tracking using Linux control groups.

In simple terms, it helps us manage the lifecycle of services. You can add services to startup jobs, if your services die, it can auto restart and much more. 

## Making a simple flask application (our service)
Requirements:
- python3 installed 
- pip3 installed

Install flask using pip3
```bash
sudo pip3 install flask
```

### Make a basic flask application

Make a file `main.py`, place it in any folder ex - `/home/mridul/main.py` and add the following contents in it.
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello World!'

app.run(port=8000)
```

### Run and test the flask app

To run out flask server - 
```bash
/usr/bin/python3 /home/mridul/main.py
```

To test if our application is running -
```bash
curl http://localhost:8000
```
You should be able to see Hello World! in the curl output.



## Making a systemd entry

To begin with the systemd service entry will be stored in `/etc/systemd/system/`
So, create a new file `/etc/systemd/system/flaskapp.service`
```ini
[Unit]
Description=Simple flask app service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=mridul
ExecStart=/usr/bin/python3 /home/mridul/main.py

[Install]
WantedBy=multi-user.target
```

Most of the above fields are easy to understand. The `After` field is used to start our service only after the network service runs. We can also put something else like `mysql.target` to run it after mysql service runs.

In the `User` field, we need to provice which user should the service be run from, for our example we can run it from my user i.e. `mridul`.

The `ExecStart` is where we give the command to run our service.

`Restart` is used to specify the behavior when our service dies due to some reason. setting it to `always` will restart our service everytime it dies, even if it exited with status code `0`. To restart only in case of failure we can set it to `on-failure`.

## Basic systemd commands

To start our service
```bash
sudo systemctl start flaskapp
```

To stop our service
```bash
sudo systemctl stop flaskapp
```

To restart our service
```bash
sudo systemctl restart flaskapp
```

To check status of our service
```bash
sudo systemctl status flaskapp
```

To start our service during system startup
```bash
sudo systemctl enable flaskapp
```