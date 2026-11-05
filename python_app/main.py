import json
import socket

LOCATIONS = {
    "home":   {"name": "Home",   "description": "Your cozy room.",
               "actions": ["study", "sleep"], "exits": ["school", "mall", "park"],
               "characters": []},
    "school": {"name": "School", "description": "The local high school.",
               "actions": ["study"], "exits": ["home", "mall"],
               "characters": ["mia"]},
    "mall":   {"name": "Mall",   "description": "Busy shopping center.",
               "actions": ["work", "shop"], "exits": ["home", "school", "park"],
               "characters": ["luna"]},
    "park":   {"name": "Park",   "description": "Quiet green space.",
               "actions": ["relax"], "exits": ["home", "mall"],
               "characters": ["sam"]},
}

CHARACTERS = {
    "mia":  {"name": "Mia",  "role": "Classmate"},
    "luna": {"name": "Luna", "role": "Shopkeeper"},
    "sam":  {"name": "Sam",  "role": "Childhood friend"},
}

TIMES = ["morning", "afternoon", "evening", "night"]

class GameState:
    def __init__(self):
        self.day = 1
        self.time_idx = 0
        self.money = 100
        self.energy = 100
        self.location = "home"
        self.affection = {c: 0 for c in CHARACTERS}
        self.message = "You wake up in your room. It's going to be a long day."

    @property
    def time(self):
        return TIMES[self.time_idx]

    def next_time(self):
        self.time_idx += 1
        if self.time_idx >= len(TIMES):
            self.time_idx = 0
            self.day += 1
            self.energy = min(100, self.energy + 30)

    def to_dict(self):
        loc = LOCATIONS[self.location]
        available_actions = []
        for a in loc["actions"]:
            if a == "study" and self.energy < 10: continue
            if a == "work" and self.energy < 20: continue
            available_actions.append(a)
        return {
            "day": self.day, "time": self.time,
            "money": self.money, "energy": self.energy,
            "location": self.location,
            "location_name": loc["name"],
            "location_description": loc["description"],
            "affection": self.affection,
            "characters_here": [
                {"id": c, "name": CHARACTERS[c]["name"],
                 "affection": self.affection[c]}
                for c in loc["characters"]
            ],
            "message": self.message,
            "actions": available_actions,
            "moves": loc["exits"],
        }

state = GameState()

def handle(cmd):
    global state
    cmd = cmd.strip()
    if cmd in ("", "state"):
        return state.to_dict()

    if cmd == "reset":
        state = GameState()
        return state.to_dict()

    if cmd.startswith("action:"):
        action = cmd.split(":", 1)[1]
        loc = LOCATIONS[state.location]
        if action not in loc["actions"]:
            state.message = "You can't do that here."
        elif action == "study":
            if state.energy < 10:
                state.message = "You're too tired to study."
            else:
                state.energy -= 10
                state.affection["mia"] = min(100, state.affection["mia"] + 1)
                state.message = "You studied hard. Mia noticed (+1 affection)."
                state.next_time()
        elif action == "work":
            if state.energy < 20:
                state.message = "You're too tired to work."
            else:
                state.energy -= 20
                state.money += 30
                state.message = "You worked a shift (+$30)."
                state.next_time()
        elif action == "sleep":
            state.time_idx = 0
            state.day += 1
            state.energy = 100
            state.location = "home"
            state.message = "A new day dawns. Day %d." % state.day
        elif action == "relax":
            state.energy = min(100, state.energy + 10)
            state.message = "You relaxed in the park (+10 energy)."
            state.next_time()
        elif action == "shop":
            if state.money < 20:
                state.message = "You can't afford anything."
            else:
                state.money -= 20
                state.message = "You bought a small gift (-$20)."
        return state.to_dict()

    if cmd.startswith("move:"):
        dest = cmd.split(":", 1)[1]
        if dest in LOCATIONS[state.location]["exits"]:
            state.location = dest
            state.message = "You walk to the %s." % LOCATIONS[dest]["name"]
            state.next_time()
        else:
            state.message = "You can't go there from here."
        return state.to_dict()

    if cmd.startswith("talk:"):
        npc = cmd.split(":", 1)[1]
        if npc in LOCATIONS[state.location]["characters"]:
            state.affection[npc] = min(100, state.affection[npc] + 2)
            state.message = "You chatted with %s (+2 affection)." % CHARACTERS[npc]["name"]
            state.next_time()
        else:
            state.message = "They're not here."
        return state.to_dict()

    return {"error": "unknown: " + cmd, **state.to_dict()}


def serve():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("127.0.0.1", 8000))
    s.listen(8)
    print("SummerDay backend ready on 127.0.0.1:8000", flush=True)
    while True:
        try:
            conn, _ = s.accept()
            raw = conn.recv(4096).decode("utf-8", "replace").strip()
            try:
                resp = json.dumps(handle(raw))
            except Exception as e:
                resp = json.dumps({"error": str(e)})
            conn.sendall(resp.encode())
            conn.close()
        except Exception as e:
            print("error:", e, flush=True)

serve()
