package sonic;

import haxe.Json;
import sys.io.File;
import Raylib.Image;
import Raylib.Texture2D;
import Raylib.Colors;

typedef IntPoint = {
	x:Int,
	y:Int
}

typedef LevelData = {
	tileset:String,
	tiles:Array<Array<Int>>
}

@:access(sonic.Object)
class Level {
	static inline var TILE_SIZE:Int = 16;

	public var texture:Texture2D;

	var tileset:Array<IntPoint> = [];
	var tiles:Array<Array<Int>> = [];

	function checkTile(image:Image, x:Int, y:Int):IntPoint {
		x = x * TILE_SIZE;
		y = y * TILE_SIZE;
		for (px in 0...TILE_SIZE) {
			for (py in 0...TILE_SIZE) {
				final color = Raylib.getImageColor(image, x + px, y + py);
				if (color.a == 255)
					return {x: x, y: y};
			}
		}
		return null;
	}

	public function new(id:String) {
		final data:LevelData = Json.parse(File.getContent('assets/levels/$id.json'));
		final imagePath = 'assets/tilesets/${data.tileset}.png';
		final image = Raylib.loadImage(imagePath);
		tiles = data.tiles;

		for (y in 0...Std.int(image.height / TILE_SIZE)) {
			for (x in 0...Std.int(image.width / TILE_SIZE)) {
				final tile = checkTile(image, x, y);
				if (tile != null)
					tileset.push(tile);
			}
		}

		texture = Raylib.loadTextureFromImage(image);
		Raylib.unloadImage(image);
	}

	public function draw() {
		var set:Array<Int>;
		for (i in 0...tiles.length) {
			set = tiles[i];
			Object.origin.y = i * TILE_SIZE;
			for (y in 0...set.length) {
				final tile = tileset[set[y]];

				Object.source.x = tile.x;
				Object.source.y = tile.y;
				Object.source.width = TILE_SIZE;
				Object.source.height = TILE_SIZE;

				Object.origin.x = y * TILE_SIZE;

				Raylib.drawTextureRec(texture, Object.source, Object.origin, Colors.WHITE);
			}
		}
	}
}
