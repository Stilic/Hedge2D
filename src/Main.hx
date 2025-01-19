import raylib.Raylib.*;
import sonic.states.State;
import sonic.states.EditorState;

class Main {
	public static inline var DEBUG:Bool = true;
	public static var state:State;

	function new() {
		InitWindow(320, 224, "Hedge2D");
		SetTargetFPS(60);

		// final sonic = new Sonic();
		// sonic.y = 5 * 16;

		state = new EditorState();

		while (!WindowShouldClose()) {
			final frameTime = GetFrameTime();

			state.update(frameTime);

			// sonic.update(frameTime);

			BeginDrawing();
			ClearBackground(BLUE);

			// sonic.draw();

			state.draw();

			EndDrawing();
		}

		state.unload();
		// UnloadTexture(sonic.texture);
		CloseWindow();
	}

	static function main() {
		new Main();
	}
}
