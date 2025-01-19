package sonic;

import haxe.Json;
import sys.io.File;
import raylib.Raylib.*;
import raylib.Types;

// TODO: add objects
class Layer {
	public function draw(alpha:Int = 255) {}
}

@:access(sonic.Object)
class TiledLayer extends Layer {
	public var set(default, null):String;
	public var tileSize(default, null):Int;

	public var texture(default, null):Texture;
	public var tiles:Array<Array<Int>>;

	public var lines(default, null):Int;
	public var columns(default, null):Int;

	public function new(set:String, tiles:Array<Array<Int>>, tileSize:Int = 16) {
		this.set = set;
		texture = Cache.getTexture('tilesets/${set}');

		this.tileSize = tileSize;
		lines = Std.int(texture.height / tileSize);
		columns = Std.int(texture.width / tileSize);

		this.tiles = tiles;
	}

	public function drawTile(x:Float, y:Float, tile:Int, alpha:Int) {
		Object.source.x = tile * tileSize;
		Object.source.y = Std.int(tile / columns) * tileSize;
		Object.source.width = tileSize;
		Object.source.height = tileSize;

		Object.origin.x = x;
		Object.origin.y = y;

		Object.color.a = alpha;

		DrawTextureRec(texture, Object.source, Object.origin, Object.color);
	}

	override function draw(alpha:Int = 255) {
		var set:Array<Int>;
		var y:Int;
		for (i in 0...tiles.length) {
			set = tiles[i];
			y = i * tileSize;
			for (x in 0...set.length) {
				final tile = set[x];
				if (tile != 0)
					drawTile(x * tileSize, y, tile - 1, alpha);
			}
		}
	}
}

class CollisionLayer extends Layer {
	public var tileSize(default, null):Int = 16;

	public var image(default, null):Image;
	public var tiles:Array<Array<Int>>;

	public var lines(default, null):Int;
	public var columns(default, null):Int;

	public function new(tiles:Array<Array<Int>>) {
		image = Cache.getImage('tilesets/collision');

		lines = Std.int(image.height / tileSize);
		columns = Std.int(image.width / tileSize);

		this.tiles = tiles;
	}
}

class Level {
	var path:String;

	public var layers(default, null):Array<Layer> = [];

	public function new(id:String) {
		path = 'assets/levels/$id.json';
		final data = Json.parse(File.getContent(path));
		if (Reflect.hasField(data, "layers")) {
			for (layer in cast(data.layers, Array<Dynamic>)) {
				if (Reflect.hasField(layer, "type"))
					switch (cast(layer.type, String)) {
						case "collision":
							if (Reflect.hasField(layer, "tiles"))
								layers.push(new CollisionLayer(layer.tiles));
						case "tiled":
							if (Reflect.hasField(layer, "set") && Reflect.hasField(layer, "tiles"))
								layers.push(new TiledLayer(layer.set, layer.tiles));
					}
			}
		} else
			throw "No `layers` field found.";
	}

	public function draw(?mainLayer:Layer) {
		for (layer in layers) {
			if (mainLayer != null && mainLayer != layer)
				layer.draw(127);
			else
				layer.draw();
		}
	}

	public function save() {
		final layersData:Array<Any> = [];
		for (layer in layers) {
			if (layer is TiledLayer) {
				final layer:TiledLayer = cast layer;
				if (layer.set == "collision")
					layersData.push({type: "collision", tiles: layer.tiles});
				else
					layersData.push({type: "tiled", set: layer.set, tiles: layer.tiles});
			} else if (layer is CollisionLayer)
				layersData.push({type: "collision", tiles: cast(layer, CollisionLayer).tiles});
		}
		File.saveContent(path, Json.stringify({layers: layersData}));
	}
}
