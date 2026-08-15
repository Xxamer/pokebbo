import {
  Application,
  Assets,
  AnimatedSprite,
  Sprite,
  Texture,
  Text,
  TextStyle,
} from "pixi.js";

const RoomGame = {
  async mounted() {
    // Initiate pixi
    this.app = new Application();

    await this.app.init({
      resizeTo: this.el,
      background: "#1a1a1a",
      antialias: false,
    });

    this.el.appendChild(this.app.canvas);

    const backgroundTexture = await Assets.load("/backgrounds/room.jpg");
    this.background = new Sprite(backgroundTexture);
    this.resizeBackground();
    this.app.stage.addChild(this.background);

    // We load the walk animation, idk how this work
    const walkTexture = await Assets.load("/avatars/bulbasaur/Walk-Anim.png");
    this.animations = this.createAnimations(walkTexture);
    this.players = new Map();

    const playerId = String(this.el.dataset.playerId);
    const username = this.el.dataset.username;
    this.localPlayerId = playerId;
    this.createPlayer({
      id: playerId,
      username: username,
      x: 300,
      y: 300,
      direction: "down",
      local: true,
    });

    this.app.stage.eventMode = "static";
    this.app.stage.hitArea = this.app.screen;

    this.app.stage.on("pointerdown", (event) => {
      const player = this.players.get(this.localPlayerId);
      if (!player) {
        console.error("Local player not found:", this.localPlayerId);
        return;
      }
      player.target.x = event.global.x;
      player.target.y = event.global.y;
      this.updateDirection(player);
      player.isMoving = true;
      this.setWalk(player);
    });

    this.app.ticker.add((ticker) => {
      this.updatePlayers(ticker.deltaTime);
    });

    this.resizeHandler = () => {
      this.resizeBackground();
      this.app.stage.hitArea = this.app.screen;
      this.players.forEach((player) => {
        this.updatePlayerNamePosition(player);
      });
    };

    this.handleEvent("player_joined", (player) => {
      console.log("Player joined:", player);
      if (String(player.id) === this.localPlayerId) {
        return;
      }
      this.createPlayer({
        id: player.id,
        username: player.username,
        x: player.x,
        y: player.y,
        direction: player.direction,
        local: false,
      });
    });
    this.handleEvent("player_left", (player) => {
      console.log("Player left:", player.id);

      this.removePlayer(player.id);
    });
    window.addEventListener("resize", this.resizeHandler);
  },

  createAnimations(texture) {
    const frameWidth = 40;
    const frameHeight = 40;
    const rows = 8;
    const columns = 6;
    const directions = [
      "down",
      "down-right",
      "right",
      "up-right",
      "up",
      "up-left",
      "left",
      "down-left",
    ];
    const animations = {};
    for (let row = 0; row < rows; row++) {
      const frames = [];
      for (let column = 0; column < columns; column++) {
        frames.push(
          new Texture({
            source: texture.source,
            frame: {
              x: column * frameWidth,
              y: row * frameHeight,
              width: frameWidth,
              height: frameHeight,
            },
          }),
        );
      }
      animations[directions[row]] = frames;
    }
    return animations;
  },
  createPlayer({ id, username, x, y, direction = "down", local = false }) {
    const playerId = String(id);
    const sprite = new AnimatedSprite(this.animations[direction]);
    sprite.anchor.set(0.5);
    sprite.x = x;
    sprite.y = y;
    sprite.animationSpeed = 0.15;
    sprite.loop = true;
    this.app.stage.addChild(sprite);

    // Display current player name on avatar

    const nameStyle = new TextStyle({
      fontFamily: "Arial",
      fontSize: 14,

      fill: "#ffffff",

      stroke: {
        color: "#000000",
        width: 3,
      },
    });

    const nameText = new Text({
      text: username,
      style: nameStyle,
    });

    nameText.anchor.set(0.4, 1);

    this.app.stage.addChild(nameText);

    // =========================
    // Player object
    // =========================

    const player = {
      id: playerId,
      username,
      sprite,
      nameText,
      x,
      y,
      direction,
      target: {
        x,
        y,
      },
      isMoving: false,
      local,
    };

    this.players.set(playerId, player);
    this.updatePlayerNamePosition(player);
    this.setIdle(player);
    return player;
  },

  // We need to remove the players
  removePlayer(id) {
    const player = this.players.get(String(id));
    if (!player) {
      return;
    }
    this.app.stage.removeChild(player.sprite);
    this.app.stage.removeChild(player.nameText);
    player.sprite.destroy();
    player.nameText.destroy();
    this.players.delete(String(id));
  },

  // =========================
  // Update all players
  // =========================

  updatePlayers(delta) {
    this.players.forEach((player) => {
      if (!player.isMoving) {
        this.updatePlayerNamePosition(player);

        return;
      }

      this.updatePlayer(player, delta);
    });
  },

  // =========================
  // Update player movement
  // =========================

  updatePlayer(player, delta) {
    const dx = player.target.x - player.sprite.x;

    const dy = player.target.y - player.sprite.y;

    const distance = Math.sqrt(dx * dx + dy * dy);

    // =========================
    // Target reached
    // =========================

    if (distance < 2) {
      player.sprite.x = player.target.x;

      player.sprite.y = player.target.y;

      player.x = player.sprite.x;

      player.y = player.sprite.y;

      player.isMoving = false;

      this.setIdle(player);

      this.updatePlayerNamePosition(player);

      return;
    }

    // =========================
    // Movement speed
    // =========================

    const speed = 3;

    player.sprite.x += (dx / distance) * speed * delta;

    player.sprite.y += (dy / distance) * speed * delta;

    player.x = player.sprite.x;

    player.y = player.sprite.y;

    this.updatePlayerNamePosition(player);
  },

  // =========================
  // Calculate direction
  // =========================

  updateDirection(player) {
    const dx = player.target.x - player.sprite.x;

    const dy = player.target.y - player.sprite.y;

    const angle = Math.atan2(dy, dx);

    const degrees = (angle * 180) / Math.PI;

    if (degrees >= -22.5 && degrees < 22.5) {
      player.direction = "right";
    } else if (degrees >= 22.5 && degrees < 67.5) {
      player.direction = "down-right";
    } else if (degrees >= 67.5 && degrees < 112.5) {
      player.direction = "down";
    } else if (degrees >= 112.5 && degrees < 157.5) {
      player.direction = "down-left";
    } else if (degrees >= 157.5 || degrees < -157.5) {
      player.direction = "left";
    } else if (degrees >= -157.5 && degrees < -112.5) {
      player.direction = "up-left";
    } else if (degrees >= -112.5 && degrees < -67.5) {
      player.direction = "up";
    } else {
      player.direction = "up-right";
    }
  },

  // =========================
  // Walk animation
  // =========================

  setWalk(player) {
    const frames = this.animations[player.direction];

    player.sprite.textures = frames;

    player.sprite.animationSpeed = 0.15;

    player.sprite.loop = true;

    player.sprite.play();
  },

  // =========================
  // Idle animation
  // =========================

  setIdle(player) {
    const frames = this.animations[player.direction];

    player.sprite.stop();

    player.sprite.textures = frames;

    player.sprite.gotoAndStop(0);
  },

  // =========================
  // Update player name
  // =========================

  updatePlayerNamePosition(player) {
    if (!player || !player.sprite || !player.nameText) {
      return;
    }
    player.nameText.x = player.sprite.x;
    player.nameText.y = player.sprite.y - player.sprite.height / 2 - 4;
  },

  // =========================
  // Resize background
  // =========================

  resizeBackground() {
    if (!this.background || !this.app) {
      return;
    }

    this.background.width = this.app.screen.width;

    this.background.height = this.app.screen.height;
  },

  // =========================
  // Destroy
  // =========================

  destroyed() {
    console.log("RoomGame destroyed");

    if (this.resizeHandler) {
      window.removeEventListener("resize", this.resizeHandler);
    }

    if (this.app) {
      this.app.destroy(true);
    }

    if (this.players) {
      this.players.clear();
    }
  },
};

export default RoomGame;
