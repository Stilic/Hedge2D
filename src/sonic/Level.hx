package sonic;

import haxe.Json;
import sys.io.File;
import raylib.Raylib.*;
import raylib.Types;
import sonic.Common;

class Layer {
	// TODO: add objects
}

interface ITileContainer {
	var tileSize(default, null):Int;
	var tiles:Array<Array<Int>>;
	var lines(default, null):Int;
	var columns(default, null):Int;
}

@:access(sonic.Object)
class TiledLayer extends Layer implements ILoader implements IDrawable implements ITileContainer {
	public var tileSize(default, null):Int;

	public var texture(default, null):Texture;
	public var tiles:Array<Array<Int>>;

	public var lines(default, null):Int;
	public var columns(default, null):Int;

	public function new(tileset:String, tiles:Array<Array<Int>>, tileSize:Int = 16) {
		texture = LoadTexture('assets/tilesets/${tileset}.png');

		this.tileSize = tileSize;
		lines = Std.int(texture.height / tileSize);
		columns = Std.int(texture.width / tileSize);

		this.tiles = tiles;
	}

	public function drawTile(x:Float, y:Float, tile:Int, color:Color) {
		Object.source.x = tile * tileSize;
		Object.source.y = Std.int(tile / columns) * tileSize;
		Object.source.width = tileSize;
		Object.source.height = tileSize;

		Object.origin.x = x;
		Object.origin.y = y;

		DrawTextureRec(texture, Object.source, Object.origin, color);
	}

	public function draw() {
		var set:Array<Int>;
		var y:Int;
		for (i in 0...tiles.length) {
			set = tiles[i];
			y = i * tileSize;
			for (x in 0...set.length) {
				final tile = set[x];
				if (tile != 0)
					drawTile(x * tileSize, y, tile - 1, WHITE);
			}
		}
	}

	public function unload() {
		UnloadTexture(texture);
	}
}

// TODO: revert tile size back to 16
class CollisionLayer extends Layer implements ILoader implements ITileContainer {
	public var tileSize(default, null):Int = 32;

	public var image(default, null):Image;
	public var tiles:Array<Array<Int>>;

	public var lines(default, null):Int;
	public var columns(default, null):Int;

	public function new(tiles:Array<Array<Int>>) {
		image = LoadImage('assets/tilesets/collision.png');

		lines = Std.int(image.height / tileSize);
		columns = Std.int(image.width / tileSize);

		this.tiles = tiles;
	}

	public function unload() {
		UnloadImage(image);
	}
}

class Level implements ILoader {
	var path:String;

	public var layers(default, null):Array<Layer> = [];

	public function new(id:String, debug:Bool = true) {
		path = 'assets/levels/$id.json';
		final data = Json.parse(File.getContent(path));
		if (Reflect.hasField(data, "layers")) {
			for (layer in cast(data.layers, Array<Dynamic>)) {
				if (Reflect.hasField(layer, "type"))
					switch (cast(layer.type, String)) {
						case "collision":
							if (Reflect.hasField(layer, "tiles"))
							{
								if (debug)
									layers.push(new TiledLayer("collision", layer.tiles, 32));
								else
									layers.push(new CollisionLayer(layer.tiles));
							}
						case "tiled":
							if (Reflect.hasField(layer, "set") && Reflect.hasField(layer, "tiles"))
								layers.push(new TiledLayer(layer.set, layer.tiles));
					}
			}
		} else
			throw "No `layers` field found.";
	}

	public function draw() {
		for (layer in layers) {
			if (layer is IDrawable)
				cast(layer, IDrawable).draw();
		}
	}

	public function unload() {
		for (layer in layers) {
			if (layer is ILoader)
				cast(layer, ILoader).unload();
		}
	}

	// public function save() {
	// 	final data:LevelData = {tileset: tileset, tiles: tiles};
	// 	File.saveContent(path, Json.stringify(data));
	// }
}
