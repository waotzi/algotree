const std = @import("std");
const rl = @import("raylib");
const tree = @import("tree.zig");

const print = std.debug.print;

fn min(a: f16, b: f16) f16 { if (a < b) { return a; } else { return b; } }


pub fn main() void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const background_color = rl.Color{.r = 40, .g = 7, .b = 40, .a = 255};
    const screen_width = 800;
    const screen_height = 600;
    rl.SetConfigFlags(@enumToInt(rl.ConfigFlags.FLAG_WINDOW_RESIZABLE));
    rl.InitWindow(screen_width, screen_height, "algotree");
    rl.SetTargetFPS(60);
    
    // Render texture initialization, used to hold the rendering result so we can easily resize it
    var target = rl.LoadRenderTexture(screen_width, screen_height);
    rl.SetTextureFilter(target.texture, @enumToInt(rl.TextureFilter.TEXTURE_FILTER_BILINEAR));

    // init audio device
    rl.InitAudioDevice();

    // setup camera
    var camera = rl.Camera2D{
        .offset = rl.Vector2{.x = 0, .y = 0},
        .target = rl.Vector2{.x = 0, .y = 0},
        .rotation = 0,
        .zoom = 1
    };
    // load tree
    var sakura = tree.new();
    sakura.load();
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.WindowShouldClose()) {
        // Update
        //----------------------------------------------------------------------------------
        // update screen scale
        const scale = min(@intToFloat(f16, rl.GetScreenWidth()) / screen_width,  @intToFloat(f16, rl.GetScreenHeight()) / screen_height);
        // key listener
        if (rl.IsKeyPressed(rl.KeyboardKey.KEY_F)) rl.ToggleFullscreen();
        // update tree
        sakura.update();
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.BeginDrawing();
        rl.ClearBackground(background_color);
        rl.BeginTextureMode(target);
        rl.BeginMode2D(camera);
        sakura.draw();
        rl.EndMode2D();
        rl.EndTextureMode();
        // Draw RenderTexture2D to window
        const texture_rect = rl.Rectangle{.x = 0, .y = 0, .width = @intToFloat(f16, target.texture.width), .height = @intToFloat(f16, -target.texture.height)};
        const screen_rect = rl.Rectangle{.x = (@intToFloat(f16, rl.GetScreenWidth()) - screen_width * scale) * 0.5, .y = (@intToFloat(f16, rl.GetScreenHeight()) - screen_height * scale) * 0.5, .width = screen_width * scale, .height = screen_height * scale};
        rl.DrawTexturePro(target.texture, texture_rect, screen_rect, rl.Vector2{.x = 0, .y = 0}, 0.0, rl.WHITE);
        rl.EndDrawing();
      
        // reset cursor image
        rl.SetMouseCursor(@enumToInt(rl.MouseCursor.MOUSE_CURSOR_DEFAULT));
        //----------------------------------------------------------------------------------
    }
    // De-Initialization
    //--------------------------------------------------------------------------------------
    // unload tree
    sakura.unload();
    // unload devices
    rl.CloseAudioDevice();
    // close window
    rl.CloseWindow();
    //--------------------------------------------------------------------------------------

}
