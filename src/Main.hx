import raylib.Raylib.*;
import raylib.Types;
import sonic.Util;
import sonic.Level;
import sonic.characters.Sonic;

class Main {
	var level:Level;
	var currentLayer:TiledLayer;
	var tile = 1;

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
			if (layer is TiledLayer) {
				currentLayer = cast layer;
				break;
			}
		}

		final sonic = new Sonic();
		sonic.y = 5 * currentLayer.tileSize;

		final editorTileColor = new Color(255, 255, 255, 128);
		var editorLastX = -1;
		var editorLastY = -1;

		while (!WindowShouldClose()) {
			final dt = GetFrameTime();
			sonic.update(dt);

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

			// if ((IsKeyDown(KEY_LEFT_CONTROL) || IsKeyDown(KEY_RIGHT_CONTROL)) && IsKeyPressed(KEY_S))
			// 	level.save();

			BeginDrawing();
			ClearBackground(BLUE);

			sonic.draw();
			level.draw();

			currentLayer.drawTile(tileX * currentLayer.tileSize, tileY * currentLayer.tileSize, tile, editorTileColor);

			EndDrawing();
		}

		UnloadTexture(level.texture);
		UnloadTexture(sonic.texture);
		CloseWindow();
	}

	static function main() {
		new Main();
	}
}
