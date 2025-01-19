package sonic.states;

import raylib.Raylib.*;
import raylib.Types;
import sonic.Level;

class PlayState extends State {
	var level:Level;

	public function new(level:Level) {
		this.level = level;

		for (i in 0...level.layers.length) {
			final layer = level.layers[i];
			if (layer is TiledLayer) {
				final layer:TiledLayer = cast layer;
				if (layer.set == "collision")
					level.layers[i] = new CollisionLayer(layer.tiles);
			}
		}
	}

	override function update(frameTime:Float) {
		if (IsKeyPressed(KEY_ENTER))
			Main.state = new EditorState(level);

		super.update(frameTime);
	}

	override function draw() {
		super.draw();

		level.draw();
	}
}
