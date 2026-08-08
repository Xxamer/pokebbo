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

    // =========================
    // Background
    // =========================

    const backgroundTexture = await Assets.load(
      "/backgrounds/room.jpg",
    );

    this.background = new Sprite(backgroundTexture);

    this.resizeBackground();

    this.app.stage.addChild(this.background);

    // =========================
    // Player
    // =========================

    const texture = await Assets.load(
      "/avatars/bulbasaur/Attack-Anim.png",
    );

    const frameWidth = 64;
    const frameHeight = 64;

    const frames = [];

    for (let row = 0; row < 8; row++) {
      for (let col = 0; col < 11; col++) {
        frames.push(
          new Texture({
            source: texture.source,
            frame: {
              x: col * frameWidth,
              y: row * frameHeight,
              width: frameWidth,
              height: frameHeight,
            },
          }),
        );
      }
    }

    this.player = new AnimatedSprite(frames);
    this.player.x = 300;
    this.player.y = 300;
    this.player.animationSpeed = 0.15;
    this.player.loop = true;
    this.app.stage.addChild(this.player);
    this.player2 = new AnimatedSprite(frames);
    this.player2.x = 360;
    this.player2.y = 360;
    this.player2.animationSpeed = 0.15;
    this.player2.loop = true;
    this.app.stage.addChild(this.player2);

    this.player.play();
    this.player2.play();

    // =========================
    // Resize
    // =========================

    this.resizeHandler = () => {
      this.resizeBackground();
    };

    window.addEventListener("resize", this.resizeHandler);
  },

  resizeBackground() {
    if (!this.background || !this.app) return;
    this.background.width = this.app.screen.width;
    this.background.height = this.app.screen.height;
  },

  destroyed() {
    console.log("RoomGame destroyed");

    if (this.resizeHandler) {
      window.removeEventListener("resize", this.resizeHandler);
    }

    if (this.app) {
      this.app.destroy(true);
    }
  },
};

export default RoomGame;