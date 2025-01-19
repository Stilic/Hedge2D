package sonic;

import raylib.Raylib.*;
import raylib.Types;

final class Cache {
	public static inline var PREFIX = "assets/";

	public static final images:Map<String, Image> = [];
	public static final textures:Map<String, Texture> = [];

	public static function getImage(path:String):Image {
		path = '${PREFIX}images/$path.png';
		if (images.exists(path))
			return images.get(path);

		final asset = LoadImage(path);
		images.set(path, asset);
		return asset;
	}

	public static function getTexture(path:String):Texture {
		path = '${PREFIX}images/$path.png';
		if (textures.exists(path))
			return textures.get(path);

		final asset = LoadTexture(path);
		textures.set(path, asset);
		return asset;
	}

	// public static function clear() {
	// 	for (key => image in images) {
	// 		UnloadImage(image);
	// 		images.remove(key);
	// 	}

	// 	for (key => texture in textures) {
	// 		UnloadTexture(texture);
	// 		textures.remove(key);
	// 	}
	// }
}
