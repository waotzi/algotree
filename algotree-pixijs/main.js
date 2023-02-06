//Aliases
const Application = PIXI.Application,
    loader = PIXI.Loader.shared;

//Create a Pixi Application
const app = new PIXI.Application({ 
    width: 800,         // default: 800
    height: 600,        // default: 600
    antialias: true,    // default: false
    transparent: false, // default: false
    resolution: 1       // default: 1
  }
);
app.renderer.backgroundColor = 0x270729;
app.renderer.view.style.position = "absolute";
app.renderer.view.style.display = "block";
app.renderer.autoDensity = true;
app.resizeTo = window;

document.body.appendChild(app.view);

loader.load(setup);

var t1;
function setup() {
	t1 = Object.create(tree);
	t1.load();
	//Start the game loop 
	app.ticker.add((delta) => gameLoop(delta));
}

function gameLoop(delta) {
	t1.update(delta);
	t1.draw();
}
