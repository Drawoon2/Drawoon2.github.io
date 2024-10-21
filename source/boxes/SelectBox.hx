package boxes;

import Selector;
import Text;
import TextBox;

class SelectBox extends TextBox
{
	static public var selectFunc:String->Void;

	var curSelect(default, set):Int = 0;

	var options:Array<String> = ["fight", "pokemon", "item", "run"];
	var optionsTXT:Array<Text> = [];

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y, 12, 6);

		var fightText = new Text(16, 16, "LUCHA");
		optionsTXT.push(fightText);
		add(fightText);

		var pokemonText = new Text(64, 16, "pokemon");
		optionsTXT.push(pokemonText);
		add(pokemonText);

		var itemText = new Text(16, 32, "OBJ.");
		optionsTXT.push(itemText);
		add(itemText);

		var runText = new Text(64, 32, "ESC");
		optionsTXT.push(runText);
		add(runText);

		selector = new Selector(8, 16);
		add(selector);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls != null)
		{
			var moveX:Int = (controls.LEFT.justPressed ? -1 : 0) + (controls.RIGHT.justPressed ? 1 : 0);
			var moveY:Int = (controls.UP.justPressed ? -1 : 0) + (controls.DOWN.justPressed ? 1 : 0);
			if (Math.abs(moveX) > 0 || Math.abs(moveY) > 0)
			{
				switch (curSelect % 2)
				{
					case 0:
						if (moveX < 0)
							moveX = 0;
					case 1:
						if (moveX > 0)
							moveX = 0;
				}
				switch (curSelect)
				{
					case 0 | 1:
						if (moveY < 0)
							moveY = 0;
					case 2 | 3:
						if (moveY > 0)
							moveY = 0;
				}
				curSelect += moveY * 2 + moveX;
			}
			if (controls.ACCEPT.justPressed)
			{
				if (selectFunc != null)
					selectFunc(options[curSelect]);
			}
		}
	}

	function set_curSelect(value:Int):Int
	{
		if (curSelect != value)
		{
			selector.x = optionsTXT[value].x - 8;
			selector.y = optionsTXT[value].y;
		}
		return curSelect = value;
	}
}
