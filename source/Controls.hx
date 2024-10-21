package;

import flixel.input.keyboard.FlxKey;

class Controls
{
	public var ACCEPT(default, null):KeyControl;
	public var BACK(default, null):KeyControl;
	public var UP(default, null):KeyControl;
	public var DOWN(default, null):KeyControl;
	public var LEFT(default, null):KeyControl;
	public var RIGHT(default, null):KeyControl;

	public function new()
	{
		ACCEPT = new KeyControl([SPACE, ENTER]);
		BACK = new KeyControl([ESCAPE, BACKSPACE]);
		UP = new KeyControl([FlxKey.UP, W]);
		DOWN = new KeyControl([FlxKey.DOWN, S]);
		LEFT = new KeyControl([FlxKey.LEFT, A]);
		RIGHT = new KeyControl([FlxKey.RIGHT, D]);
	}
}

class KeyControl
{
	public var pressed(get, null):Bool = false;
	public var justPressed(get, null):Bool = false;

	var keys:Array<FlxKey> = [];

	public function new(keys:Array<FlxKey>)
	{
		this.keys = keys;
	}

	function get_pressed()
	{
		return FlxG.keys.anyPressed(keys);
	}

	function get_justPressed()
	{
		return FlxG.keys.anyJustPressed(keys);
	}
}
