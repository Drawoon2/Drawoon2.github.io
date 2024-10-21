package;

import Utils.Direction;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class Lines extends FlxSpriteGroup
{
	var spritesGroup:Array<FlxSprite> = [];
	var GRID_SIZE:Int = 8;

	public function new(x:Float = 0, y:Float = 0, sizeX:Int = 3, sizeY:Int = 2, ?direction:Direction = RIGHT)
	{
		super(x, y);
		for (i in 0...4)
		{
			var sprite = new FlxSprite().loadGraphic(Paths.images("battleHUD/hudLine"), true, 8, 8);
			switch (i)
			{
				case 0:
					sprite.animation.add("idle", [3], 1);
					sprite.animation.add("corner", [0], 1);
					sprite.animation.play(direction == RIGHT ? "corner" : "idle", true);
				case 1:
					sprite.animation.add("horizontal", [4], 1);
					sprite.animation.play("horizontal", true);
					sprite.setGraphicSize(GRID_SIZE * (sizeX - 2), GRID_SIZE);

				case 2:
					sprite.animation.add("idle", [2], 1);
					sprite.animation.add("corner", [1], 1);
					sprite.animation.play(direction == RIGHT ? "idle" : "corner", true);
				case 3:
					sprite.animation.add("vertical", [5], 1);
					sprite.animation.play("vertical", true);
					sprite.setGraphicSize(GRID_SIZE, GRID_SIZE * (sizeY - 1));
			}
			sprite.updateHitbox();
			if (i >= 0 && i <= 2)
				sprite.y = GRID_SIZE * (sizeY - 1);
			switch (i)
			{
				case 1:
					sprite.x = GRID_SIZE;
				case 2:
					sprite.x = GRID_SIZE * (sizeX - 1);
				case 3:
					if (direction == LEFT)
						sprite.x += GRID_SIZE * (sizeX - 1);
			}
			add(sprite);
		}
	}
}
