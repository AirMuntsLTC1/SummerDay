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
        # The Cinematic Story Queue
        self.dialogue_queue = [
            {"bg": "bus", "text": "It's been three years since I left this town..."},
            {"bg": "bus", "text": "Now I'm back. 18 years old, with nothing but a suitcase and a vague memory of this place."},
            {"bg": "house", "text": "My mother left me the old house. It's dusty, but it's mine now."},
            {"bg": "bedroom", "text": "I walk inside and drop my bags. The room is exactly how I remember it."},
            {"bg": "bedroom", "text": "Exhausted from the trip, I collapse onto the bed..."},
            {"bg": "bedroom", "text": "Tomorrow is a new day. Time to see what this town has to offer."}
        ]
        return self.get_next_dialogue()

    def get_next_dialogue(self):
        if self.dialogue_queue:
            current = self.dialogue_queue.pop(0)
            self.message = current["text"]
            return {
                "phase": "intro",
                "text": current["text"],
                "bg": current["bg"],
                "is_last": len(self.dialogue_queue) == 0
            }
        else:
            self.phase = "room"
            self.message = "You wake up in your bedroom. The sun is shining."
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
        return state.get_next_dialogue()
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
