import {
  Application,
  Assets,
  AnimatedSprite,
  Sprite,
  Texture,
} from "pixi.js";

const RoomGame = {
  async mounted() {
    this.app = new Application();

    await this.app.init({
      resizeTo: this.el,
      background: "#1a1a1a",
      antialias: false,
    });

    this.el.appendChild(this.app.canvas);
    const backgroundTexture = await Assets.load(
      "/backgrounds/room.jpg"
    );
    this.background = new Sprite(backgroundTexture);
    this.resizeBackground();
    this.app.stage.addChild(this.background);
    
    const walkTexture = await Assets.load(
      "/avatars/bulbasaur/Walk-Anim.png"
    );
    const frameWidth = 40;
    const frameHeight = 40;
    const rows = 8;
    const columns = 6;
    // we create the animations
    this.animations = {};
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

    for (let row = 0; row < rows; row++) {
      const frames = [];
      for (let column = 0; column < columns; column++) {
        const frame = new Texture({
          source: walkTexture.source,
          frame: {
            x: column * frameWidth,
            y: row * frameHeight,
            width: frameWidth,
            height: frameHeight,
          },
        });

        frames.push(frame);
      }

      this.animations[directions[row]] = frames;
    }

    console.log("Animations:", this.animations);

    // =========================
    // Player
    // =========================

    this.player = new AnimatedSprite(
      this.animations.down
    );
    this.player.anchor.set(0.5);
    this.player.x = 300;
    this.player.y = 300;
    this.player.animationSpeed = 0.25;
    this.player.loop = true;
    this.app.stage.addChild(this.player);
    // Current direction
    this.direction = "down";
    // Current target
    this.target = {
      x: this.player.x,
      y: this.player.y,
    };

    this.isMoving = false;

    // Start idle
    this.setIdle();

    // =========================
    // Click to move
    // =========================

    this.app.stage.eventMode = "static";
    this.app.stage.hitArea = this.app.screen;

    this.app.stage.on("pointerdown", (event) => {
      this.target.x = event.global.x;
      this.target.y = event.global.y;

      this.updateDirection();

      this.isMoving = true;

      this.setWalk();
    });

    // =========================
    // Game loop
    // =========================

    this.app.ticker.add((ticker) => {
      this.updatePlayer(ticker.deltaTime);
    });

    // =========================
    // Resize
    // =========================

    this.resizeHandler = () => {
      this.resizeBackground();

      this.app.stage.hitArea = this.app.screen;
    };

    window.addEventListener(
      "resize",
      this.resizeHandler
    );
  },

  // =========================
  // Movement
  // =========================

  updatePlayer(delta) {
    if (!this.isMoving) {
      return;
    }

    const dx = this.target.x - this.player.x;
    const dy = this.target.y - this.player.y;

    const distance = Math.sqrt(
      dx * dx + dy * dy
    );

    // Reached target
    if (distance < 2) {
      this.player.x = this.target.x;
      this.player.y = this.target.y;

      this.isMoving = false;

      this.setIdle();

      return;
    }

    const speed = 3;

    this.player.x +=
      (dx / distance) * speed * delta;

    this.player.y +=
      (dy / distance) * speed * delta;
  },

  // =========================
  // Direction
  // =========================

  updateDirection() {
    const dx = this.target.x - this.player.x;
    const dy = this.target.y - this.player.y;

    const angle = Math.atan2(dy, dx);

    const degrees =
      (angle * 180) / Math.PI;

    if (degrees >= -22.5 && degrees < 22.5) {
      this.direction = "right";
    } else if (
      degrees >= 22.5 &&
      degrees < 67.5
    ) {
      this.direction = "down-right";
    } else if (
      degrees >= 67.5 &&
      degrees < 112.5
    ) {
      this.direction = "down";
    } else if (
      degrees >= 112.5 &&
      degrees < 157.5
    ) {
      this.direction = "down-left";
    } else if (
      degrees >= 157.5 ||
      degrees < -157.5
    ) {
      this.direction = "left";
    } else if (
      degrees >= -157.5 &&
      degrees < -112.5
    ) {
      this.direction = "up-left";
    } else if (
      degrees >= -112.5 &&
      degrees < -67.5
    ) {
      this.direction = "up";
    } else {
      this.direction = "up-right";
    }
  },

  // =========================
  // Walk animation
  // =========================

  setWalk() {
    const frames = this.animations[this.direction];

    this.player.textures = frames;

    this.player.animationSpeed = 0.15;

    this.player.loop = true;

    this.player.play();
  },

  // =========================
  // Idle animation
  // =========================

  setIdle() {
    const frames = this.animations[this.direction];
    this.player.stop();
    this.player.textures = frames;
    // First frame = idle
    this.player.gotoAndStop(0);
  },
  resizeBackground() {
    if (!this.background || !this.app) {
      return;
    }
    this.background.width =
      this.app.screen.width;
    this.background.height =
      this.app.screen.height;
  },

  // =========================
  // Destroy
  // =========================

  destroyed() {
    console.log("RoomGame destroyed");

    if (this.resizeHandler) {
      window.removeEventListener(
        "resize",
        this.resizeHandler
      );
    }

    if (this.app) {
      this.app.destroy(true);
    }
  },
};

export default RoomGame;