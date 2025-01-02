import raylib.Raylib.*;
import sonic.Level;
import sonic.characters.Sonic;

class Main {
	static function main() {
		InitWindow(320, 224, "Sonic Eclipse");
		SetTargetFPS(60);

		final level = new Level("ghz1");

		final sonic = new Sonic();
		sonic.y = 80;

		while (!WindowShouldClose()) {
			final dt = GetFrameTime();
			sonic.update(dt);

			BeginDrawing();
			ClearBackground(BLUE);

			level.draw();
			sonic.draw();

			EndDrawing();
		}

		UnloadTexture(level.texture);
		UnloadTexture(sonic.texture);
		CloseWindow();
	}
}
