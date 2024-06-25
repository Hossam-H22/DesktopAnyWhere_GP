import { Server } from 'socket.io';



export function checkAvailability(ip, type) {
    var found = false;
    devices.forEach(device => {
        if (device['ip'] == ip && device['type'] == type) {
            found = true;
        }
    });
    return found
}

export function refreshDevicesConnection(ip){
    devices.forEach(device => {
        if (device['ip'] == ip) {
            io.to(device.id).emit("refreshConnection", "refresh");
        }
    });
}

var devices = [];
var io;

const initSocket = (server) => {

    io = new Server(server, {
        cors: '*'
    });

    io.on("connection", (socket) => {
        // console.log(socket.id);


        // socket.emit("event", {
        //     "ip": "192.168.1.9", // 
        //     "type": "", // mobile or desktop or web
        //     "target_type": "", // mobile or desktop or web
        //     "event": "home", // target event
        //     "message":{
        //         "":"",
        //     },
        //     "eventError": "error", // error event if target not found
        //     "messageError": {
        //         "":"",
        //     },
        // })


        socket.on("event", (data) => {
            const { event, message } = data;
            console.log(`event => ${event}`);
            var found = false

            devices.forEach(receiver => {
                if (receiver['ip'] == data['ip'] && receiver['type'] == data['target_type']) {
                    found = true;
                    io.to(receiver.id).emit(event, message);
                }
            });

            if (found == false)
                socket.emit(data["eventError"], { ip: data['ip'], messageError: data["messageError"], lostData: message })
        })

        socket.on("checkAvailableDevice", (data) => {
            console.log("checkAvailableDevice");
            var found = checkAvailability(data['ip'], data['target_type']);
            socket.emit("checkIPResult", {
                "message": found ? "found" : "Please check the IP",
                "found": found,
                "note": data["note"],
            });
        });

        socket.on("addDevice", (data) => {
            console.log("addDevice");
            const newDevices = devices.filter(device => {
                return !(device['ip'] == data['ip'] && device['type'] == data['type']);
                // return !( device['ip'] == data['ip'] && device['type'] == data['type'] && (data['type'] == "desktop" || data['type'] == "web") );
                // return !(device['id'] == socket.id);
            });
            devices = newDevices;
            devices.push({
                id: socket.id,
                ...data,
            });
            console.log(devices);
        });

        socket.on("disconnect", () => {
            console.log("disconnect");
            const newDevices = devices.filter(device => {
                return device['id'] != socket.id;
            });
            devices = newDevices;
            console.log(devices);
        });

        socket.on("getStunAndTurn", async () => {
            const stun = await stunModel.find();
            var newStun = []
            stun?.forEach(element => {
                newStun.push(element.url);
            });

            const turn = await turnModel.find();
            var newTurn = []
            turn?.forEach(element => {
                newTurn.push({
                    "urls": element.url,
                    "username": element.username,
                    "credential": element.credential,
                });
            });
            var configuration = {
                "iceServers": [
                    {
                        'urls': newStun
                    },
                    ...newTurn,
                ]
            }

            socket.emit("receiveStunAndTurn", configuration);
        });

    });






}

export default initSocket