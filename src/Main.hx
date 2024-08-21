import Raylib.Colors;
import sonic.Level;
import sonic.characters.Sonic;

class Main {
	static function main() {
		Raylib.initWindow(320, 224, "Sonic Eclipse");
		Raylib.setTargetFPS(60);

		final level = new Level("ghz1");

		final sonic = new Sonic();
		sonic.y = 80;

		while (!Raylib.windowShouldClose()) {
			final dt = Raylib.getFrameTime();
			sonic.update(dt);

			Raylib.beginDrawing();
			Raylib.clearBackground(Colors.BLUE);

			level.draw();
			sonic.draw();

			Raylib.endDrawing();
		}

		Raylib.unloadTexture(level.texture);
		Raylib.unloadTexture(sonic.texture);
		Raylib.closeWindow();
	}
}
