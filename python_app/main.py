import json
import socket

TIMES = ["Morning", "Afternoon", "Evening", "Night"]

class GameState:
    def __init__(self):
        self.phase = "intro"
        self.player_name = "Player"
        self.avatar = "default"
        self.stats = {"INT": 1, "CHA": 1, "AGI": 1, "STR": 1}
        self.day = 1
        self.time_idx = 0
        self.money = 0
        self.location = "bedroom"
        self.quests = []
        self.dialogue_queue = []
        self.message = ""

    @property
    def time(self):
        return TIMES[self.time_idx]

    def set_setup(self, data):
        self.player_name = data.get("name", "Player")
        self.avatar = data.get("avatar", "default")
        preset = data.get("preset", "zero")
        if preset == "zero":
            self.stats = {"INT": 1, "CHA": 1, "AGI": 1, "STR": 1}
            self.money = 0
        elif preset == "mod":
            self.stats = {"INT": 5, "CHA": 5, "AGI": 5, "STR": 5}
            self.money = 100
        elif preset == "full":
            self.stats = {"INT": 10, "CHA": 10, "AGI": 10, "STR": 10}
            self.money = 500
        self.phase = "intro"
        self.dialogue_queue = [
            f"Hello {self.player_name}...",
            "You wake up in your childhood home.",
            "Your mother left you this house before she passed.",
            "It's been a year. The town hasn't changed much.",
            "But you have. You're 18 now. It's time to make your mark.",
            "You look around your room. The day is just beginning."
        ]
        self.message = self.dialogue_queue.pop(0)
        return self.to_dict()

    def next_dialogue(self):
        if self.dialogue_queue:
            self.message = self.dialogue_queue.pop(0)
            if not self.dialogue_queue:
                self.phase = "room"
        else:
            self.phase = "room"
        return self.to_dict()

    def interact(self, target):
        if target == "bed":
            self.message = "You feel refreshed. Energy restored."
        elif target == "mirror":
            self.message = f"You look at yourself, {self.player_name}. Ready for the day."
            if "Find a Job" not in self.quests:
                self.quests.append("Find a Job")
                self.message += "\n[NEW QUEST: Find a Job]"
        elif target == "door":
            self.message = "You walk out into the hallway."
            self.location = "hallway"
        elif target == "mia":
            self.message = "Mia: 'Oh! Hey neighbor. I heard you were back in town.'"
            if "Find a Job" not in self.quests:
                self.quests.append("Find a Job")
                self.message += "\n[NEW QUEST: Find a Job]"
        return self.to_dict()

    def to_dict(self):
        hotspots = []
        characters = []
        if self.phase == "room":
            # Format: x%, y%, width%, height%
            hotspots = [
                {"id": "door", "x": 0.8, "y": 0.4, "w": 0.15, "h": 0.4, "label": "Door"},
                {"id": "bed", "x": 0.1, "y": 0.6, "w": 0.25, "h": 0.3, "label": "Bed"},
                {"id": "mirror", "x": 0.45, "y": 0.2, "w": 0.1, "h": 0.2, "label": "Mirror"}
            ]
            if self.location == "bedroom":
                characters = [
                    {"id": "mia", "name": "Mia", "x": 0.3, "y": 0.4, "w": 0.2, "h": 0.4}
                ]

        return {
            "phase": self.phase,
            "player_name": self.player_name,
            "avatar": self.avatar,
            "stats": self.stats,
            "day": self.day,
            "time": self.time,
            "money": self.money,
            "location": self.location,
            "quests": self.quests,
            "message": self.message,
            "hotspots": hotspots,
            "characters": characters
        }

state = GameState()

def handle(raw):
    global state
    try:
        req = json.loads(raw)
    except:
        req = {"action": "state"}

    act = req.get("action")
    
    if act == "setup":
        return state.set_setup(req)
    elif act == "next_dialogue":
        return state.next_dialogue()
    elif act == "interact":
        return state.interact(req.get("target"))
    
    return state.to_dict()

def serve():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("127.0.0.1", 8000))
    s.listen(8)
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
