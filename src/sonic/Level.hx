package sonic;

import haxe.Json;
import sys.io.File;
import raylib.Raylib.*;
import raylib.Types;

typedef LevelData = {
	tileset:String,
	tiles:Array<Array<Int>>
}

@:access(sonic.Object)
class Level {
	public static inline var TILE_SIZE:Int = 16;

	var path:String;
	var tileset:String;

	public var texture(default, null):Texture;

	public var lines(default, null):Int;
	public var columns(default, null):Int;

	public var tiles:Array<Array<Int>>;

	public function new(id:String) {
		path = 'assets/levels/$id.json';
		final data:LevelData = Json.parse(File.getContent(path));

		tileset = data.tileset;
		final texturePath = 'assets/tilesets/${tileset}.png';
		texture = LoadTexture(texturePath);

		lines = Std.int(texture.height / TILE_SIZE);
		columns = Std.int(texture.width / TILE_SIZE);

		tiles = data.tiles;
	}

	public function save() {
		final data:LevelData = {tileset: tileset, tiles: tiles};
		File.saveContent(path, Json.stringify(data));
	}

	public function drawTile(x:Float, y:Float, tile:Int, color:Color) {
		Object.source.x = tile * TILE_SIZE;
		Object.source.y = Std.int(tile / columns) * TILE_SIZE;
		Object.source.width = TILE_SIZE;
		Object.source.height = TILE_SIZE;

		Object.origin.x = x;
		Object.origin.y = y;

		DrawTextureRec(texture, Object.source, Object.origin, color);
	}

	public function draw() {
		var set:Array<Int>;
		var y:Int;
		for (i in 0...tiles.length) {
			set = tiles[i];
			y = i * TILE_SIZE;
			for (x in 0...set.length) {
				final tile = set[x];
				if (tile != 0)
					drawTile(x * TILE_SIZE, y, tile - 1, WHITE);
			}
		}
	}
}
