# Pokebbo

Pokebbo is a multiplayer virtual-room chat application inspired by
pixel worlds.

---

## ✨ Features

- Create temporary rooms
- List active rooms
- Join and leave rooms
- Choose a unique username (IN DEVELOPMENT)
- Store player identity in the session (IN DEVELOPMENT)
- Real-time chat 
- Multiplayer room state
- Pixel-art avatars
- PixiJS-based game world
- Player movement
- Real-time player synchronization

> Rooms are currently stored in memory and disappear when the server stops.

---

## 🧱 Tech Stack

### Backend

- Elixir
- Phoenix
- Phoenix LiveView
- GenServer
- DynamicSupervisor
- Phoenix.PubSub

### Frontend

- Phoenix LiveView
- PixiJS
- Tailwind CSS
- daisyUI

---

# 🏗 Architecture

The application is divided into two main layers:

```text
                         ┌──────────────────────┐
                         │      Browser         │
                         │                      │
                         │  LiveView + PixiJS   │
                         └──────────┬───────────┘
                                    │
                           WebSocket / LiveView
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │     Phoenix Web      │
                         │                      │
                         │     LiveViews        │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │     Room Registry    │
                         │                      │
                         │  DynamicSupervisor   │
                         └──────────┬───────────┘
                                    │
                         ┌──────────┴──────────┐
                         │                     │
                         ▼                     ▼
                  ┌─────────────┐       ┌─────────────┐
                  │   Room 1    │       │   Room 2    │
                  │  GenServer  │       │  GenServer  │
                  └─────────────┘       └─────────────┘