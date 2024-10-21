package boxes;

import TextBox;
import pokeStuff.*;

class MoveBox extends TextBox
{
	var moveSelect:Array<String> = [];

	var moveTypeTxt:Text;

	var movePPTxt:Text;

	var movesTXT:Array<Text> = [];

	var pokeMove:Array<Move> = [];

	var curSelect(default, set):Int = 0;

	static var lastSelect:Int = 0;

	public static var callback:Move->Void = null;

	public var isSelect:Bool = false;

	public function new(x:Float = 0, y:Float = 0, pokemon:Pokemon = null)
	{
		super(x, y, 16, 6);

		var infoBox = new TextBox(-32, -32, 11, 5);
		add(infoBox);
		var typeText = new Text(8, 8, "TIPO/");
		infoBox.add(typeText);

		moveTypeTxt = new Text(16, 16, "NORMAL");
		infoBox.add(moveTypeTxt);

		movePPTxt = new Text(40, 24, "00/00");
		infoBox.add(movePPTxt);

		selector = new Selector(8, 8);
		add(selector);

		if (pokemon != null)
			pokeMove = pokemon.movesList;

		for (i in 0...4)
		{
			var moveTXT = new Text(16, 8 + 8 * i, "-");
			if (pokeMove[i] != null)
				moveTXT.text = pokeMove[i].realName;
			movesTXT.push(moveTXT);
			add(moveTXT);
		}

		curSelect = lastSelect;

		moveUpdate();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls != null)
		{
			var move:Int = (controls.UP.justPressed ? -1 : 0) + (controls.DOWN.justPressed ? 1 : 0);
			if (Math.abs(move) > 0)
			{
				curSelect += move;
				moveUpdate();
			}
			if (controls.ACCEPT.justPressed)
			{
				if (pokeMove[curSelect].canUse)
				{
					if (callback != null)
						callback(pokeMove[curSelect]);
				}
				else
				{
					trace("You can't use " + pokeMove[curSelect].realName);
				}
			}
		}
	}

	function set_curSelect(value:Int):Int
	{
		value %= 4;
		if (value < 0)
			value += 4;
		if (movesTXT[value].text == "-")
			value = curSelect;
		if (curSelect != value)
		{
			selector.x = movesTXT[value].x - 8;
			selector.y = movesTXT[value].y;
			lastSelect = value;
		}
		return curSelect = value;
	}

	function moveUpdate():Void
	{
		if (pokeMove[curSelect] == null)
			return;

		var curMove = pokeMove[curSelect];
		moveTypeTxt.text = PokeTypes.translateType(curMove.type);

		movePPTxt.text = Utils.loadNumber(curMove.curPP) + "/" + Utils.loadNumber(curMove.maxPP);
	}
}
