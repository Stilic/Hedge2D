package sonic.states;

import raylib.Raylib.*;
import raylib.Types;
import sonic.Util;
import sonic.Level;

class EditorState extends State {
	final editorTileColor = new Color(255, 255, 255, 128);

	var level:Level;
	var layers:Array<TiledLayer> = [];
	var currentLayer:TiledLayer;
	var currentLayerIndex:Int = 0;
	var tile:Int = 1;

	var tileX:Int;
	var tileY:Int;
	var lastX:Int;
	var lastY:Int;

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

	public function new() {
		level = new Level("ghz1");
		for (layer in level.layers) {
			if (layer is TiledLayer)
				layers.push(cast layer);
		}
		currentLayer = layers[currentLayerIndex];
	}

	override function update(frameTime:Float) {
		super.update(frameTime);

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
		tileX = Std.int(mousePosition.x / currentLayer.tileSize);
		tileY = Std.int(mousePosition.y / currentLayer.tileSize);
		if (lastX != tileX || lastY != tileY) {
			lastX = tileX;
			lastY = tileY;
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
	}

	override function draw() {
		super.draw();
		currentLayer.draw();
		currentLayer.drawTile(tileX * currentLayer.tileSize, tileY * currentLayer.tileSize, tile, editorTileColor);
	}

	override function unload() {
		super.unload();
		level.unload();
	}
}
