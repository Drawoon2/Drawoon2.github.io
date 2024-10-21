package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import pokeStuff.Pokemon;
import pokeStuff.StatuProblem;

class LevelText extends FlxSpriteGroup
{
	public var pokemon(default, set):Pokemon;
	public var haveEffect:Bool = false;
	public var effect:String = "";

	public var textLvl:Text;

	public var textEffect:Text;

	public function new(x:Float = 0, y:Float = 0, pokemon:Pokemon)
	{
		super(x, y);

		var lvlTxt = new FlxSprite().loadGraphic(Paths.images('battleHUD/lvlTxt'));
		add(lvlTxt);

		textLvl = new Text(8, 0, "0");
		add(textLvl);

		textEffect = new Text(0, 0, effect);
		add(textEffect);
		textEffect.visible = haveEffect;

		this.pokemon = pokemon;
	}

	function set_pokemon(value:Pokemon)
	{
		if (value != pokemon)
		{
			updateLvl(value);
		}

		return pokemon = value;
	}

	override function update(elapsed:Float)
	{
		if (pokemon != null)
		{
			haveEffect = pokemon.haveNoVolatil;
			if (haveEffect)
				updateLvl(pokemon);
		}

		super.update(elapsed);
	}

	function updateLvl(?poke:Pokemon)
	{
		if (poke == null)
			poke = pokemon;

		if (poke != null)
		{
			textLvl.text = Std.string(poke.level);
			effect = effectToString(poke.noVolatilEffects);
			textEffect.text = effect;
			textEffect.visible = haveEffect;
		}
	}

	function effectToString(effect:StatuProblem = null):String
	{
		if (effect != null)
			return switch (effect.status)
			{
				case "PAR": "PAR";
				case "SLP": "DOR";
				case "FRZ": "CON";
				case "PSN" | "BPSN": "EVN";
				case "BRN": "QUE";
				case "DEB": "DEB";
				default: "";
			}
		return "";
	}
}
