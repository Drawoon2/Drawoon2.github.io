package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class TextBox extends FlxSpriteGroup
{
	static var grid_size:Int = 8;

	var sprites:Array<FlxSprite> = [];

	public var controls:Controls;

	var selector:Selector;

	public function new(x:Float = 0, y:Float = 0, sizeX:Int = 3, sizeY:Int = 3)
	{
		super(x, y);
		for (i in 0...9)
		{
			var spritePart:FlxSprite = new FlxSprite().loadGraphic(Paths.images('battleHUD/9slicetextbox'), true, grid_size, grid_size);
			spritePart.animation.add("idle", [i], 0, true);
			spritePart.animation.play("idle", true);
			switch (i)
			{
				case 1 | 7:
					spritePart.setGraphicSize(grid_size * (sizeX - 2), grid_size);
				case 3 | 5:
					spritePart.setGraphicSize(grid_size, grid_size * (sizeY - 2));
				case 4:
					spritePart.setGraphicSize(grid_size * (sizeX - 2), grid_size * (sizeY - 2));
			}

			spritePart.updateHitbox();
			sprites.push(spritePart);
			add(spritePart);
		}
		var partY:Float = 0;
		for (i in 0...9)
		{
			var part = sprites[i];
			if (i % 3 != 0)
			{
				part.x = sprites[i - 1].x + sprites[i - 1].width;
			}
			part.y += partY;
			if (i % 3 == 2)
				partY += sprites[i].height;
		}
	}
}
