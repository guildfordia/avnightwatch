const Max = require('max-api');

Max.post("✅ Node script started\n");

try {
  const { io } = require('socket.io-client');

  const socket = io("http://localhost:6000", {
  	transports: ["websocket"]
  });

  socket.on("connect", () => {
    Max.post("✅ Connected to Flask WebSocket\n");
  });

  socket.on("sentiment_event", (data) => {
    Max.outlet(JSON.stringify(data));
  });

  socket.on("disconnect", () => {
    Max.post("❌ Disconnected from Flask WebSocket\n");
  });

  socket.on("connect_error", (err) => {
    Max.post("❌ Connection error: " + err.message + "\n");
  });

} catch (err) {
  Max.post("❌ Script error: " + err.message + "\n");
}
