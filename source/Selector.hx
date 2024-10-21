package;

import flixel.FlxSprite;

class Selector extends FlxSprite
{
	public function new(x:Float = 0, y:Float = 0, lookTo:String = "right")
	{
		super(x, y);

		loadGraphic(Paths.images('battleHUD/selectors'), true, 8, 8);
		animation.add("right_white", [0], 0, true);
		animation.add("right", [1], 0, true);
		animation.add("down", [2], 0, true);
		animation.play(lookTo, true);
	}

	public function change(lookTo:String)
	{
		animation.play(lookTo, true);
	}
}
