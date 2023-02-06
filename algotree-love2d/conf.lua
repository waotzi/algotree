-- Configuration
function love.conf(t)
	t.title = "algotree" -- The title of the window the game is in (string)
	t.version = "11.4" -- The LÖVE version this game was made for (string)
	t.window.width = 800 -- we want our game to be long and thin.
	t.window.height = 600

	-- For Windows debugging
	t.console = false
end
