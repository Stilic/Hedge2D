package sonic;

import raylib.Raylib.*;
import raylib.Types;

class Object {
	static final source:Rectangle = new Rectangle(0, 0, 0, 0);
	static final destination:Rectangle = new Rectangle(0, 0, 0, 0);
	static final origin:Vector2 = new Vector2(0, 0);

	static inline function getSizeFromRadius(radius:Int):Int
		return radius == 0 ? 0 : radius * 2 + 1;

	public var x:Float = 0;
	public var y:Float = 0;
	public var angle:Float = 0;

	public var xSpeed:Float = 0;
	public var ySpeed:Float = 0;

	public var groundSpeed:Float = 0;
	public var groundAngle:Float = 0;

	var _width:Int = 0;
	var _height:Int = 0;
	var _hitboxWidth:Int = 0;
	var _hitboxHeight:Int = 0;

	public var width(get, never):Int;
	public var height(get, never):Int;
	public var hitboxWidth(get, never):Int;
	public var hitboxHeight(get, never):Int;

	public var widthRadius(default, set):Int = 0;
	public var heightRadius(default, set):Int = 0;
	public var hitboxWidthRadius(default, set):Int = 0;
	public var hitboxHeightRadius(default, set):Int = 0;

	public var texture:Texture;
	public var flipX:Bool = false;
	public var flipY:Bool = false;

	public function update(dt:Float) {
		// TODO: animation system
	}

	public function draw() {
		final halfWidth = texture.width / 2;
		final halfHeight = texture.height / 2;

		source.x = 0;
		source.y = 0;
		source.width = flipX ? -texture.width : texture.width;
		source.height = flipY ? -texture.height : texture.height;

		destination.x = x + halfWidth;
		destination.y = y + halfHeight;
		destination.width = texture.width;
		destination.height = texture.height;

		origin.x = halfWidth;
		origin.y = halfHeight;

		DrawTexturePro(texture, source, destination, origin, angle, WHITE);
	}

	@:noCompletion
	inline public function get_width():Int
		return _width;

	@:noCompletion
	inline public function get_height():Int
		return _height;

	@:noCompletion
	inline public function get_hitboxWidth():Int
		return _hitboxWidth;

	@:noCompletion
	inline public function get_hitboxHeight():Int
		return _hitboxHeight;

	@:noCompletion
	public function set_widthRadius(newValue:Int):Int {
		_width = getSizeFromRadius(newValue);
		return widthRadius = newValue;
	}

	@:noCompletion
	public function set_heightRadius(newValue:Int):Int {
		_height = getSizeFromRadius(newValue);
		return heightRadius = newValue;
	}

	@:noCompletion
	public function set_hitboxWidthRadius(newValue:Int):Int {
		_hitboxWidth = getSizeFromRadius(newValue);
		return hitboxWidthRadius = newValue;
	}

	@:noCompletion
	public function set_hitboxHeightRadius(newValue:Int):Int {
		_hitboxHeight = getSizeFromRadius(newValue);
		return hitboxHeightRadius = newValue;
	}
}
