var errorModal = document.getElementById("errorModal")

var socket = io();
socket.on("room_closed", (data) => {
    console.log("Room_Closed")
    errorModal.style.display = "block";
});
