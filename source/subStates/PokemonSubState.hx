package subStates;

import boxes.MainBox;
import boxes.MultOptionBox;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import pokeStuff.Pokemon;
import pokeStuff.Trainer;

class PokemonSubState extends FlxSubState
{
	public var controls:Controls;

	var pokeDatas:Array<PokemonData> = [];

	var selector:Selector;

	var mainTextBox:MainBox;

	var curSelect(default, set):Int = 0;

	public var onSelect:Pokemon->Void;

	var afterDEB:Bool = false;
	var inBattle:Bool = true;

	var box:MultOptionBox = null;

	var trainer:Trainer;

	public function new(trainer:Trainer, inBattle:Bool = true, hasDEB:Bool = false)
	{
		super(0xfff8f8f8);
		this.inBattle = inBattle;
		this.trainer = trainer;
		afterDEB = hasDEB;
		var yPos:Float = 0;
		for (poke in trainer.team)
		{
			var pokeData:PokemonData = new PokemonData(8, yPos, poke);
			add(pokeData);
			pokeDatas.push(pokeData);
			yPos += 16;
		}
		pokeDatas[curSelect].playAnim("select");
		selector = new Selector(0, 8);
		add(selector);
		mainTextBox = new MainBox(0, 96);
		add(mainTextBox);

		if (afterDEB)
			mainTextBox.mainText.text = "¿Qué POKÉMON quieres utilizar?";
		else
			mainTextBox.mainText.text = "Elige un POKÉMON.";
	}

	var canControl:Bool = true;

	override function update(elapsed:Float)
	{
		if (controls != null)
		{
			if (canControl)
			{
				mainTextBox.controls = null;
				selector.change("right");
				if (controls.BACK.justPressed)
				{
					close();
				}
				var move:Int = (controls.UP.justPressed ? -1 : 0) + (controls.DOWN.justPressed ? 1 : 0);
				if (Math.abs(move) > 0)
				{
					curSelect += move;
					selector.y = pokeDatas[curSelect].y + 8;
				}

				if (controls.ACCEPT.justPressed)
				{
					if (pokeDatas[curSelect].pokemon.canContinue && trainer.curPokemon != pokeDatas[curSelect].pokemon)
					{
						if (afterDEB)
						{
							changePokemon(pokeDatas[curSelect]);
						}
						else
						{
							canControl = false;
							selector.change("right_white");
							box = new MultOptionBox(88, 88, inBattle ? ["CAMBIO", "ESTAD.", "SALIR"] : ["ESTAD.", "CAMBIO", "SALIR"], true);
							box.onSelect = function(option:String)
							{
								switch (option)
								{
									case "CAMBIO":
										if (inBattle && pokeDatas[curSelect].pokemon != trainer.curPokemon)
											changePokemon(pokeDatas[curSelect]);
									case "ESTAD.":
									//
									default:
										remove(box);
										canControl = true;
								}
							}
							add(box);
						}
					}
					else
					{
						canControl = false;
						var quote = pokeDatas[curSelect].pokemon.name + " ya esta luchando";
						if (pokeDatas[curSelect].pokemon.canContinue)
							quote = pokeDatas[curSelect].pokemon.name + " no puede luchar";
						mainTextBox.erase();
						mainTextBox.write(quote, function()
						{
							mainTextBox.erase();
							if (afterDEB)
								mainTextBox.mainText.text = "¿Qué POKÉMON quieres utilizar?";
							else
								mainTextBox.mainText.text = "Elige un POKÉMON.";

							canControl = true;
						});
					}
				}
			}
			else
			{
				if (box != null)
					box.controls = controls;
				mainTextBox.controls = controls;
			}
		}

		super.update(elapsed);
	}

	function changePokemon(pokeData:PokemonData)
	{
		if (onSelect != null)
			onSelect(pokeData.pokemon);

		close();
	}

	function set_curSelect(value:Int)
	{
		pokeDatas[curSelect].playAnim("idle");
		if (value > pokeDatas.length - 1)
			value = pokeDatas.length - 1;
		if (value < 0)
			value = 0;

		pokeDatas[value].playAnim("select");
		return curSelect = value;
	}
}

/*
	inBattle
	CAMBIO
	ESTAD.
	SALIR
	--despues de DEB
	¿Qué POKÉMON quieres utilizar?


	outBattle
	(MO)
	ESTAD.
	CAMBIO
	SALIR

	--canviar posicion
	¿Mover POKEMON\nadonde?

 */
class PokemonData extends FlxSpriteGroup
{
	public var pokemon:Pokemon;
	public var nameText:Text;
	public var healthbar:Healthbar;
	public var lvlText:LevelText;
	public var healthText:Text;
	public var icon:FlxSprite;

	public function new(x:Float, y:Float, poke:Pokemon)
	{
		super(x, y);
		pokemon = poke;
		nameText = new Text(16, 0, pokemon.name);
		add(nameText);
		lvlText = new LevelText(96, 0, pokemon);
		lvlText.textEffect.x += 32;
		add(lvlText);
		healthbar = new Healthbar(24, 8, pokemon);
		add(healthbar);
		healthText = new Text(96, 8, "000/000");
		add(healthText);
		healthbar.text = healthText;
		icon = new FlxSprite().loadGraphic(Paths.images('pokemons/menu/' + pokemon.menuImage), true, 16, 16);
		icon.animation.add("idle", [0], 0);
		icon.animation.add("select", [0, 1], 2, true);
		icon.animation.play("idle", true);
		add(icon);
	}

	public function changePokemon(poke:Pokemon)
	{
		nameText.text = poke.name;
		lvlText.pokemon = poke;
		healthbar.pokemon = poke;
		icon.loadGraphic(Paths.images('pokemons/menu/' + pokemon.menuImage), true, 16, 16);
		icon.animation.add("idle", [0], 0);
		icon.animation.add("select", [0, 1], 2, true);
		icon.animation.play("idle", true);
		pokemon = poke;
	}

	public function playAnim(name:String)
	{
		icon.animation.play(name, true);
	}
}
