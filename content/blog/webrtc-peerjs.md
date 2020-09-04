---
title: "WebRTC using Peerjs"
date: 2020-09-01T01:26:55+05:30
slug: ""
description: "Connecting P2P using peer js"
keywords: []
draft: false
tags: ["tech","p2p","webrtc","peerjs"]
math: false
toc: true
---

## What does it mean when we say peer to peer?
P2P is direct connection between two devices to transfer data to-and-fro without the need of a central server.
The traffic does not go to or from any central server, but directly from one device to the other.

## What is WebRTC?
WebRTC stands for web real-time communications. WebRTC was not supported by all the browsers until recently and is also available in most mobile browsers.

WebRTC can be used for multiple tasks, but real-time peer-to-peer audio, video or data communications is the primary benefit.

### PeerJS
PeerJS wraps the browser's WebRTC implementation to provide a complete, configurable, and easy-to-use peer-to-peer connection API. Equipped with nothing but an ID, a peer can create a P2P data or media stream connection to a remote peer.

## Let's Start
We will make use of peerjs to communicate p2p between two different browser sessions.

To begin with make a simple html file `index.html` and put the basic html scaffold with a scirpt tag. Before the scipt tag, import the peerjs js file.
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>P2P</title>
</head>
<body>
    

    <script src="https://unpkg.com/peerjs@1.2.0/dist/peerjs.min.js"></script>
    <script>
        
    </script>
</body>
</html>
```

Next lets make a basic layout like the following - 
![Preview](/images/2020/peerjs-img1.png)

Add the following html code in the `body` - 
```html
<input id="peerid" placeholder="My ID"> 
<button onclick="join()">Join</button><br>

<input type="text" id="fpeerid" placeholder="Peer ID"> 
<button id="connect" onclick="connect()">Connect</button><br>

<input type="text" id="msg" placeholder="Message..">
<button id="send" onclick="sendMessage()">Send</button> <br>

<ul id="messages">

</ul>
```

Now starting with the js part - 

When we click on the join button, we call a join function, where we need to connect to the PeerJS Singaling server.
### Connect to signalling server
```js

var conn
var peer

function join() {
    console.log("Connecting..")
    peer = new Peer();

    // when connection is created, handle the event - 
    peer.on('open', function (id) {
        console.log('Connected to Signaling Server ID : ' + id);
        // set the input value
        var peerIDField = document.querySelector("#peerid")
        peerIDField.value = id
    });
}
```

We should be able to see our peer id when we click the join button. Next step is to try and connect to a peer id of another device. This can only be done after we are connected to the signaling server, so we can use the global `var peer` to try and connect.
### Initiate connection to a peer using their ID
```js
function connect() {
    var fpeerIDField = document.querySelector("#fpeerid")
    console.log("connecting to " + fpeerIDField.value)
    conn = peer.connect(fpeerIDField.value);

    // open event called when connection gets created
    conn.on('open', function () {
        console.log("connected")
    });
}
```

When we create a new connection, the recieving peer triggers an event `connection`, this event will come only if we have a active peer. To ensure that we can add it inside our join function and modify it as following - 
### Accept a connection coming from a Peer
```js
function join() {
    console.log("Connecting..")
    peer = new Peer();

    // when connection is created, handle the event - 
    peer.on('open', function (id) {
        console.log('Connected to Signaling Server ID : ' + id);
        // set the input value
        var peerIDField = document.querySelector("#peerid")
        peerIDField.value = id
    });

    peer.on('connection', function (c) {
        conn = c
        console.log("New connection : ")
        console.log(conn)

        // set the friend peer id we just got
        var fpeerIDField = document.querySelector("#fpeerid")
        fpeerIDField.value = c.peer
    });
}
```

Now we are able to create and accept connections. Next we need to be able to send data and recieve data.
### Send data to an active connection - 
```js
function sendMessage() {
    var msg = document.querySelector("#msg")
    console.log("sending message")
    // send message at sender or receiver side
    if (conn && conn.open) {
        printMsg("Me : " + msg.value)
        conn.send(msg.value);
    }
}

function printMsg(msg) {
    var messages = document.querySelector
    messages.innerHTML = messages.innerHTML + "<li>" + msg + "</li>"
}

```

The above code will send the message and update our list with that message using `printMsg` function. We are able to send messages, but how do we recieve them? We have two points - An initiator of the connection and a receiver of the connection.
The respective connection objects - 
- When we initiate i.e. call the connect method we get conn
- When we receive the connection in `join` using `connection` event, we get the connection in c as an arg and save it to conn global variable.

We need to handle receive of message in both these cases, so we add a data event listener in both connection event and connect function like following -
### Receive data 
```js
function join() {
    console.log("Connecting..")
    peer = new Peer();

    // when connection is created, handle the event - 
    peer.on('open', function (id) {
        console.log('Connected to Signaling Server ID : ' + id);
        // set the input value
        var peerIDField = document.querySelector("#peerid")
        peerIDField.value = id
    });

    peer.on('connection', function (c) {
        conn = c
        console.log("New connection : ")
        console.log(conn)
        
        // set the friend peer id we just got
        var fpeerIDField = document.querySelector("#fpeerid")
        fpeerIDField.value = c.peer

        // handle message receive
        conn.on('open', function () {
            // Receive messages - receiver side
            conn.on('data', function (data) {
                console.log('Received', data);
                printMsg("Friend : " + data)
            });
        });
    });
}

function connect() {
    var fpeerIDField = document.querySelector("#fpeerid")
    console.log("connecting to " + fpeerIDField.value)
    conn = peer.connect(fpeerIDField.value);

    // open event called when connection gets created
    conn.on('open', function () {
        console.log("connected")
        // Receive messages - sender side
        conn.on('data', function (data) {
            console.log('Received', data);
            printMsg("Friend : " + data)
        });
    });
}

```


If you did everything properly, we should now be able to
- register to signaling server and get our peer id
- connect to a peer id
- receive connection request from a peer
- send message to an active peer
- receive messages in both sender and receiver sides

The final code should look like the following - 
### Final Code
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>P2P</title>
</head>
<body>
    <input id="peerid" placeholder="My ID"> 
    <button onclick="join()">Join</button><br>

    <input type="text" id="fpeerid" placeholder="Peer ID"> 
    <button id="connect" onclick="connect()">Connect</button><br>

    <input type="text" id="msg" placeholder="Message..">
    <button id="send" onclick="sendMessage()">Send</button> <br>

    <ul id="messages">

    </ul>

    <script src="https://unpkg.com/peerjs@1.2.0/dist/peerjs.min.js"></script>
    <script>
        function join() {
            console.log("Connecting..")
            peer = new Peer();

            // when connection is created, handle the event - 
            peer.on('open', function (id) {
                console.log('Connected to Signaling Server ID : ' + id);
                // set the input value
                var peerIDField = document.querySelector("#peerid")
                peerIDField.value = id
            });

            peer.on('connection', function (c) {
                conn = c
                console.log("New connection : ")
                console.log(conn)
                
                // set the friend peer id we just got
                var fpeerIDField = document.querySelector("#fpeerid")
                fpeerIDField.value = c.peer

                // handle message receive
                conn.on('open', function () {
                    // Receive messages - receiver side
                    conn.on('data', function (data) {
                        console.log('Received', data);
                        printMsg("Friend : " + data)
                    });
                });
            });
        }

        function connect() {
            var fpeerIDField = document.querySelector("#fpeerid")
            console.log("connecting to " + fpeerIDField.value)
            conn = peer.connect(fpeerIDField.value);

            // open event called when connection gets created
            conn.on('open', function () {
                console.log("connected")
                // Receive messages - sender side
                conn.on('data', function (data) {
                    console.log('Received', data);
                    printMsg("Friend : " + data)
                });
            });
        }

        function sendMessage() {
            var msg = document.querySelector("#msg")
            console.log("sending message")
            // send message at sender or receiver side
            if (conn && conn.open) {
                printMsg("Me : " + msg.value)
                conn.send(msg.value);
            }
        }

        function printMsg(msg) {
            var messages = document.querySelector("#messages")
            messages.innerHTML = messages.innerHTML + "<li>" + msg + "</li>"
        }
    </script>
</body>
</html>
```

A very similar working code is present at -
- [Demo](https://mridulganga.github.io/p2p-messaging-webrtc/)
- [Source](https://github.com/mridulganga/p2p-messaging-webrtc)