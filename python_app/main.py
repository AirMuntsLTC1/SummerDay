# main.py - This runs inside the app, offline.
import json
import time

state = {"day": 1, "affection": 0, "money": 100}

def handle_command(cmd):
    global state
    if cmd == "work":
        state["money"] += 50
    elif cmd == "study":
        state["affection"] += 1
    return json.dumps(state)
