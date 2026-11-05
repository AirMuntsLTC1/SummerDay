import json
import socket

state = {"day": 1, "affection": 0, "money": 100}


def handle_command(cmd):
    global state
    if cmd == "work":
        state["money"] += 50
    elif cmd == "study":
        state["affection"] += 1
    elif cmd == "sleep":
        state["day"] += 1
    elif cmd == "reset":
        state = {"day": 1, "affection": 0, "money": 100}
    return json.dumps(state)


def serve():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("127.0.0.1", 8000))
    s.listen(8)
    print("SummerDay Python server listening on 127.0.0.1:8000", flush=True)
    while True:
        try:
            conn, _ = s.accept()
            cmd = conn.recv(1024).decode().strip() or "state"
            resp = handle_command(cmd)
            conn.sendall(resp.encode())
            conn.close()
        except Exception as e:
            print("server error:", e, flush=True)


# Blocks forever - keeps the Python subprocess alive
serve()
