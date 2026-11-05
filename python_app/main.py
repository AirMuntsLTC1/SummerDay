import json
import socket

LOCATIONS = {
    "home":   {"name": "Home",   "bg": "home_bg", "desc": "Your cozy room.",
               "actions": ["study", "sleep"], "exits": ["school", "mall", "park"],
               "characters": []},
    "school": {"name": "School", "bg": "school_bg", "desc": "The local high school.",
               "actions": ["study"], "exits": ["home", "mall"],
               "characters": ["mia"]},
    "mall":   {"name": "Mall",   "bg": "mall_bg", "desc": "Busy shopping center.",
               "actions": ["work", "shop"], "exits": ["home", "school", "park"],
               "characters": ["luna"]},
    "park":   {"name": "Park",   "bg": "park_bg", "desc": "Quiet green space.",
               "actions": ["relax"], "exits": ["home", "mall"],
               "characters": ["sam"]},
}

CHARACTERS = {
    "mia":  {"name": "Mia",  "sprite": "mia_sprite"},
    "luna": {"name": "Luna", "sprite": "luna_sprite"},
    "sam":  {"name": "Sam",  "sprite": "sam_sprite"},
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
        self.message = "You wake up in your room. Click the door to leave."

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
            
        # Build sprites list
        active_sprites = []
        for c in loc["characters"]:
            active_sprites.append({
                "id": c,
                "name": CHARACTERS[c]["name"],
                "sprite": CHARACTERS[c]["sprite"],
                "affection": self.affection[c]
            })

        return {
            "day": self.day, "time": self.time,
            "money": self.money, "energy": self.energy,
            "location": self.location,
            "location_name": loc["name"],
            "background": loc["bg"],
            "message": self.message,
            "actions": available_actions,
            "exits": loc["exits"],
            "sprites": active_sprites
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
        if action == "study":
            if state.energy >= 10:
                state.energy -= 10
                state.affection["mia"] = min(100, state.affection["mia"] + 1)
                state.message = "You studied hard. Mia noticed (+1 affection)."
                state.next_time()
            else: state.message = "Too tired to study."
        elif action == "work":
            if state.energy >= 20:
                state.energy -= 20
                state.money += 30
                state.message = "You worked a shift (+$30)."
                state.next_time()
            else: state.message = "Too tired to work."
        elif action == "sleep":
            state.time_idx = 0
            state.day += 1
            state.energy = 100
            state.location = "home"
            state.message = "A new day dawns. Day %d." % state.day
        elif action == "relax":
            state.energy = min(100, state.energy + 10)
            state.message = "You relaxed (+10 energy)."
            state.next_time()
        elif action == "shop":
            if state.money >= 20:
                state.money -= 20
                state.message = "You bought a gift (-$20)."
            else: state.message = "Not enough money."
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

    return state.to_dict()

def serve():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("127.0.0.1", 8000))
    s.listen(8)
    print("SummerDay backend ready", flush=True)
    while True:
        try:
            conn, _ = s.accept()
            raw = conn.recv(4096).decode("utf-8", "replace").strip()
            resp = json.dumps(handle(raw))
            conn.sendall(resp.encode())
            conn.close()
        except Exception as e:
            print("error:", e, flush=True)

serve()
