package battleStuff;

import Utils.Direction;
import flixel.group.FlxSpriteGroup;
import pokeStuff.Pokemon;

class BattleHUD extends FlxSpriteGroup
{
	public var pokemon(default, set):Pokemon;

	public var lines:Lines;

	public var bar:Healthbar;

	public var lvlTxt:LevelText;

	public var nameTxt:Text;

	public function new(x:Float = 0, y:Float = 0, pokemon:Pokemon, direction:Direction = LEFT)
	{
		super(x, y);

		lines = new Lines(0, direction == LEFT ? 24 : 16, 10, 2, direction);
		add(lines);

		nameTxt = new Text();

		add(nameTxt);

		bar = new Healthbar(8, 16, pokemon, direction == LEFT ? "_HUD" : "");
		add(bar);

		lvlTxt = new LevelText(direction == LEFT ? 40 : 24, 8, pokemon);
		add(lvlTxt);
		if (direction == LEFT)
		{
			nameTxt.x += 8;
			var text = new Text(16, 24, "000/000");
			add(text);
			bar.text = text;
		}

		this.pokemon = pokemon;
	}

	function set_pokemon(value:Pokemon)
	{
		nameTxt.text = value.name;
		bar.pokemon = value;
		lvlTxt.pokemon = value;
		return pokemon = value;
	}
}
