from flask import Flask, render_template, request, session, redirect, url_for
from flask_socketio import join_room, leave_room, send, SocketIO, emit, close_room
import json
from string import ascii_uppercase
import random


with open('config.json') as config_file:
    cfg = json.load(config_file)
with open('games.json') as games_cfg:
    games = json.load(games_cfg)

app = Flask(__name__)
app.config["SECRET_KEY"] = cfg['SECRET_KEY']
socket = SocketIO(app)

rooms = {}

# Generate the room code
def roomCode(len):
    while True:
        code = ""
        for i in range(len):
            code += random.choice(ascii_uppercase)
        if code not in rooms:
            break
    return code

# MaxBox Webserver

@app.route("/", methods=["POST", "GET"])
def index():
    session.clear()
    if request.method == "GET":
        return render_template("index.html")
    else:
        room = request.form.get("code").upper()
        name = request.form.get("ign")
        print(room)
        print(name)
        if room not in rooms:
            return render_template("index.html", error="Room Not Found :(")
        elif games[rooms[room]['game']]['maxplayers'] <= rooms[room]['playernum']:
            return render_template("index.html", error="Room Full :(")
        elif name in rooms[room]['players']:
            return render_template("index.html", error="That name was taken :(")
        session['room'] = room
        session['name'] = name
        session['ingame'] = False
        return redirect(url_for("game"))

@app.route("/game")
def game():
    room = session.get("room")
    if room is None or session.get("name") is None or room not in rooms:
        return redirect(url_for('index'))
    game = rooms[room]['game']
    return render_template(games[game]['page'], indexUrl=url_for('index'), title=games[game]['title'])


# Socket Io Stuff Below
@socket.on("connect")
def connect(auth):
    try:
        if auth['host']:
            game = auth['game']
            session['host'] = True
            print("Connected")
            room = roomCode(4)
            session['room'] = room
            rooms[room] = {"playernum": 0, "game": game, "host": request.sid, "players": {}}
            print(session.get('room'))
            join_room(room)
            emit("lobbyStart", {"room": room, "maxplayers": games[game]['maxplayers']}, to=room)
    except:
        room = session.get("room")
        name = session.get("name")
        if room not in rooms:
            leave_room(room)
            return
        print("Player Connected")
        session['host'] = False
        if games[rooms[room]['game']]['maxplayers'] <= rooms[room]['playernum']:
            leave_room(room)
        rooms[room]['playernum'] += 1
        rooms[room]['players'][name] = request.sid
        print(rooms[room])
        join_room(room)
        emit("playerJoin", {"name": name}, to=room)

@socket.on("disconnect")
def disconnect():
    try:
        room = session.get('room')
        if rooms[room]['host'] == request.sid:
            emit("room_closed", to=room)
            leave_room(room)
            close_room(room)
            del rooms[room]
            print("room closed: " + room)
        else:
            leave_room(room)
    except:
        leave_room(room)


if __name__ == "__main__":
    socket.run(app, debug=True, host=cfg['ip'], port=cfg['port'])