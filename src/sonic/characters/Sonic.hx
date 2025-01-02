package sonic.characters;

import raylib.Raylib.*;
import raylib.Types;

enum abstract Direction(Int) to Int {
	var Left = -1;
	var Right = 1;
}

enum Action {
	Idle;
	Walk;
	Roll;
	Spindash;
	Jump;
	Hurt;
}

// div = integer division
class Sonic extends Object {
	static inline var TOP_SPEED:Int = 6;

	// Running
	static inline var ACCELERATION_SPEED:Float = 0.046875;
	static inline var DECELERATION_SPEED:Float = 0.5;

	// Rolling
	static inline var ROLL_FRICTION_SPEED:Float = 0.0234375;
	static inline var ROLL_DECELERATION_SPEED:Float = 0.125;

	// Air state
	static inline var AIR_ACCELERATION_SPEED:Float = 0.09375;
	static inline var GRAVITY_FORCE:Float = 0.21875;
	static inline var HURT_GRAVITY_FORCE:Float = 0.1875;

	public var action:Action = Idle;
	public var onGround:Bool = true;
	public var jumpForce:Float = 6.5;

	var direction:Direction = Right;
	var spinRev:Float = 0;

	public function new() {
		widthRadius = 9;
		heightRadius = 19;
		hitboxWidthRadius = 8;
		hitboxHeightRadius = heightRadius - 3;
		texture = LoadTexture("assets/sonic.png");
	}

	inline function applyFriction(friction:Float)
		groundSpeed -= Math.min(Math.abs(groundSpeed), friction) * Util.sign(groundSpeed);

	inline function bleed(n:Float):Float
		return n - Std.int(n / 0.125) / 256;

	override function update(dt:Float) {
		if (onGround) {
			switch (action) {
				case Idle:
					if (IsKeyDown(KEY_LEFT) || IsKeyDown(KEY_RIGHT))
						action = Walk;
					else if (IsKeyDown(KEY_DOWN) && IsKeyPressed(KEY_SPACE)) {
						spinRev = 0;
						action = Spindash;
					}

				case Walk:
					if (IsKeyDown(KEY_LEFT)) {
						if (groundSpeed > 0) // if moving to the right
						{
							groundSpeed -= DECELERATION_SPEED;
							if (groundSpeed <= 0)
								groundSpeed = -0.5; // emulate deceleration quirk
						} else if (groundSpeed > -TOP_SPEED) // if moving to the left
						{
							direction = Left;
							flipX = true;
							groundSpeed -= ACCELERATION_SPEED;
							if (groundSpeed <= -TOP_SPEED)
								groundSpeed = -TOP_SPEED;
						}
					} else if (IsKeyDown(KEY_RIGHT)) {
						if (groundSpeed < 0) // if moving to the left
						{
							groundSpeed += DECELERATION_SPEED;
							if (groundSpeed >= 0)
								groundSpeed = 0.5; // emulate deceleration quirk
						} else if (groundSpeed < TOP_SPEED) // if moving to the right
						{
							direction = Right;
							flipX = false;
							groundSpeed += ACCELERATION_SPEED;
							if (groundSpeed >= TOP_SPEED)
								groundSpeed = TOP_SPEED;
						}
					} else {
						applyFriction(ACCELERATION_SPEED); // decelerate
						if (groundSpeed == 0) {
							xSpeed = 0;
							action = Idle;
						}
					}

					if (Math.abs(groundSpeed) >= 1 && IsKeyPressed(KEY_DOWN))
						action = Roll;

				case Roll:
					var friction = ROLL_DECELERATION_SPEED;
					if (groundSpeed < 0 ? IsKeyDown(KEY_RIGHT) : IsKeyDown(KEY_LEFT))
						friction += ROLL_FRICTION_SPEED;
					applyFriction(friction);

					xSpeed = Math.min(Math.abs(xSpeed), 16) * Util.sign(xSpeed);

					if (groundSpeed == 0) {
						xSpeed = 0;
						action = Idle;
					}

				case Spindash:
					if (IsKeyReleased(KEY_DOWN)) {
						groundSpeed = (8 + Math.floor(spinRev) / 2) * direction;
						action = Roll;
					} else {
						if (spinRev < 8 && IsKeyPressed(KEY_SPACE))
							spinRev += 2;
						spinRev = bleed(spinRev);
					}

				default:
			}

			if (action == Walk || action == Roll) {
				xSpeed = groundSpeed * Math.cos(groundAngle);
				ySpeed = groundSpeed * -Math.sin(groundAngle);
			}

			if (action != Spindash && IsKeyPressed(KEY_SPACE)) {
				onGround = false;
				action = Jump;

				xSpeed -= jumpForce * Math.sin(groundAngle);
				ySpeed -= jumpForce * Math.cos(groundAngle);
			}
		} else {
			// TODO: when we land, set xSpeed to 0
			final notHurt = action != Hurt;

			if (notHurt) {
				if (IsKeyDown(KEY_LEFT)) {
					if (xSpeed > -TOP_SPEED)
						xSpeed -= AIR_ACCELERATION_SPEED;
				} else if (IsKeyDown(KEY_RIGHT)) {
					if (xSpeed < TOP_SPEED)
						xSpeed += AIR_ACCELERATION_SPEED;
				}
			}

			if (notHurt && action == Jump && !IsKeyDown(KEY_SPACE))
				ySpeed = Math.max(ySpeed, -4);
			ySpeed = Math.min(ySpeed + (notHurt ? GRAVITY_FORCE : HURT_GRAVITY_FORCE), 16);

			if (notHurt && ySpeed < 0 && ySpeed > -4)
				xSpeed = bleed(xSpeed);

			if (groundAngle != 0)
				groundAngle -= Math.min(Math.abs(groundAngle), 2.8125) * Util.sign(groundAngle);
		}

		x += xSpeed;
		y += ySpeed;

		super.update(dt);
	}
}
