import raylib.Raylib.*;
import sonic.states.State;
import sonic.states.EditorState;

class Main {
	public static inline var DEBUG:Bool = true;
	public static var state(default, set):State;

	function new() {
		InitWindow(320, 224, "Hedge2D");
		SetTargetFPS(60);

		state = new EditorState();

		while (!WindowShouldClose()) {
			final frameTime = GetFrameTime();

			state.update(frameTime);

			BeginDrawing();
			ClearBackground(BLUE);

			state.draw();

			EndDrawing();
		}

		state.unload();
		CloseWindow();
	}

	static function main() {
		new Main();
	}

	static function set_state(value:State):State {
		if (state != null)
			state.unload();
		return (state = value);
	}
}
