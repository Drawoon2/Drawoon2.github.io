package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import pokeStuff.Pokemon;

class Healthbar extends FlxSpriteGroup
{
	public var pokemon(default, set):Pokemon;

	public var bar:FlxSprite;

	final maxWidth:Int = 48;

	public var percent(default, set):Float = 0;

	public var text(default, set):Text;

	public function new(x:Float = 0, y:Float = 0, pokemon:Pokemon = null, ?suffix:String = "")
	{
		super(x, y);
		final bg = new FlxSprite().loadGraphic(Paths.images('battleHUD/healthbar' + suffix));

		add(bg);

		bar = new FlxSprite(16, 3).makeGraphic(maxWidth, 2);
		add(bar);
		this.pokemon = pokemon;
	}

	var elapsedInterval:Float = 0;

	override function update(elapsed:Float)
	{
		if (pokemon != null)
			percent = pokemon.visibleHealth / pokemon.maxStats.hp;

		super.update(elapsed);
	}

	function set_pokemon(value:Pokemon)
	{
		if (value != null && value != pokemon)
			percent = value.visibleHealth / value.maxStats.hp;
		return pokemon = value;
	}

	function set_text(value:Text)
	{
		if (value != null)
			value.text = Utils.loadNumber(pokemon.visibleHealth, 3, " ") + "/" + Utils.loadNumber(pokemon.maxStats.hp, 3, " ");
		return text = value;
	}

	function set_percent(value:Float)
	{
		if (percent != value)
		{
			bar.visible = value > 0;
			bar.setGraphicSize(Std.int(value * maxWidth), 2);
			bar.updateHitbox();
			if (value > 0.5)
				bar.color = 0x00f800;
			else if (value > 0.25)
				bar.color = 0xf88800;
			else
				bar.color = 0xf80000;
		}
		if (text != null)
		{
			text.text = Utils.loadNumber(pokemon.visibleHealth, 3, " ") + "/" + Utils.loadNumber(pokemon.maxStats.hp, 3, " ");
		}
		return percent = value;
	}
}
