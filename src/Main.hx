import raylib.Raylib.*;
import raylib.Types;
import sonic.Util;
import sonic.Level;
import sonic.characters.Sonic;

class Main {
	public static inline var DEBUG:Bool = true;

	var level:Level;
	var layers:Array<TiledLayer> = [];
	var currentLayer:TiledLayer;
	var currentLayerIndex:Int = 0;
	var tile:Int = 1;

	function updateCurrentLayer(change:Int) {
		currentLayerIndex += change;
		if (currentLayerIndex < 0)
			currentLayerIndex = layers.length - 1;
		else if (currentLayerIndex > layers.length - 1)
			currentLayerIndex = 0;
		trace(currentLayerIndex);
		currentLayer = layers[currentLayerIndex];
	}

	function addTile(x:Int, y:Int) {
		final tiles = currentLayer.tiles;
		var set = tiles[y];
		if (set == null)
			set = [];
		set[x] = tile + 1;
		if (y > tiles.length) {
			for (i in tiles.length...y)
				tiles[i] = [];
		}
		tiles[y] = set;
	}

	function removeTile(x:Int, y:Int) {
		final tiles = currentLayer.tiles;
		var set = tiles[y];
		if (set != null && x < set.length) {
			set[x] = 0;
			tiles[y] = set;
		}
	}

	function new() {
		InitWindow(320, 224, "Hedge2D");
		SetTargetFPS(60);

		level = new Level("ghz1");
		for (layer in level.layers) {
			if (layer is TiledLayer)
				layers.push(cast layer);
		}
		currentLayer = layers[currentLayerIndex];

		final sonic = new Sonic();
		sonic.y = 5 * 16;

		final editorTileColor = new Color(255, 255, 255, 128);
		var editorLastX = -1;
		var editorLastY = -1;

		while (!WindowShouldClose()) {
			final dt = GetFrameTime();

			if (IsKeyPressed(KEY_DOWN) || IsKeyPressedRepeat(KEY_DOWN))
				updateCurrentLayer(-1);
			else if (IsKeyPressed(KEY_UP) || IsKeyPressedRepeat(KEY_UP))
				updateCurrentLayer(1);

			final mouseWheelMove = GetMouseWheelMove();
			if (mouseWheelMove != 0) {
				tile += Util.sign(mouseWheelMove);
				final max = currentLayer.lines * currentLayer.columns;
				if (tile < 0)
					tile = max;
				else if (tile > max)
					tile = 0;
			}

			final mousePosition = GetMousePosition();
			final tileX = Std.int(mousePosition.x / currentLayer.tileSize);
			final tileY = Std.int(mousePosition.y / currentLayer.tileSize);
			if (editorLastX != tileX || editorLastY != tileY) {
				editorLastX = tileX;
				editorLastY = tileY;
				if (IsMouseButtonDown(0))
					addTile(tileX, tileY);
				else if (IsMouseButtonDown(1))
					removeTile(tileX, tileY);
			} else if (IsMouseButtonPressed(0))
				addTile(tileX, tileY);
			else if (IsMouseButtonPressed(1))
				removeTile(tileX, tileY);

			if ((IsKeyDown(KEY_LEFT_CONTROL) || IsKeyDown(KEY_RIGHT_CONTROL)) && IsKeyPressed(KEY_S))
				level.save();

			sonic.update(dt);

			BeginDrawing();
			ClearBackground(BLUE);

			sonic.draw();
			currentLayer.draw();
			currentLayer.drawTile(tileX * currentLayer.tileSize, tileY * currentLayer.tileSize, tile, editorTileColor);

			EndDrawing();
		}

		level.unload();
		UnloadTexture(sonic.texture);
		CloseWindow();
	}

	static function main() {
		new Main();
	}
}
