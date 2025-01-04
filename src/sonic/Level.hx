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
	static inline var TILE_SIZE:Int = 16;

	public var texture:Texture;

	var columns:Int;
	var tiles:Array<Array<Int>>;

	public function new(id:String) {
		final data:LevelData = Json.parse(File.getContent('assets/levels/$id.json'));
		final texturePath = 'assets/tilesets/${data.tileset}.png';
		texture = LoadTexture(texturePath);
		columns = Std.int(texture.width / TILE_SIZE);
		tiles = data.tiles;
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
				if (tile != -1)
					drawTile(x * TILE_SIZE, y, tile, WHITE);
			}
		}
	}
}
