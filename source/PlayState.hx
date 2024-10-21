package;

import battleStuff.*;
import boxes.*;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import pokeStuff.*;
import subStates.PokemonSubState;

class PlayState extends FlxState
{
	var battleCam:FlxCamera;

	final playerPos:FlxPoint = new FlxPoint(8, 40);
	final enemyPos:FlxPoint = new FlxPoint(96, 0);

	public var player:Trainer;
	public var enemy:Trainer;

	var allBoxes:FlxTypedGroup<TextBox> = new FlxTypedGroup<TextBox>();

	public var mainBox:MainBox;

	public var controls:Controls;

	var curTxtBox:TextBox = null;

	public var hasWinner:Bool = false;

	public static var battle:PlayState;

	public var effects:EffectsAnimator;

	override public function create()
	{
		controls = new Controls();
		battleCam = new FlxCamera(0, 0, 160, 144, 4);

		battleCam.bgColor = 0xfff8f8f8;
		FlxG.cameras.add(battleCam, true);

		battle = this;
		TurnManager.battle = this;

		enemy = new Trainer(enemyPos.x, enemyPos.y, "blue", true);
		enemy.teamPrefix = "Enem.";
		add(enemy);
		for (pokemon in enemy.team)
		{
			add(pokemon);
		}

		player = new Trainer(playerPos.x, playerPos.y, "player");
		player.isPlayer = true;
		add(player);
		for (pokemon in player.team)
		{
			add(pokemon);
		}
		effects = new EffectsAnimator();
		add(effects);
		player.battleHUD = new BattleHUD(72, 56, player.curPokemon);
		add(player.battleHUD);

		enemy.battleHUD = new BattleHUD(8, 0, enemy.curPokemon, RIGHT);
		add(enemy.battleHUD);

		mainBox = new MainBox(0, 96);
		add(mainBox);
		add(allBoxes);
		SelectBox.selectFunc = function(option:String)
		{
			var newBox:TextBox = null;
			switch (option)
			{
				case "fight":
					newBox = new MoveBox(32, 96, player.curPokemon);
				case "pokemon":
					var subState:PokemonSubState = new PokemonSubState(player);
					subState.controls = controls;
					subState.onSelect = function(pokemon:Pokemon)
					{
						TurnManager.newChangesTurn(player, pokemon);
						onSelectInteraction();
					}
					openSubState(subState);
				case "item":
				case "run":
					clearBoxes();
					mainBox.write("¡No puedes escapar en una pelea con un entrenador!", function()
					{
						makeSelectBox();
					});
			}
			if (newBox != null)
			{
				addToBoxes(newBox);
			}
		}
		MoveBox.callback = onSelectMove;
		super.create();
		mainBox.write("¡" + enemy.name + " quiere luchar!", function()
		{
			player.moveTo(FlxPoint.weak(-8, 0), 0.5, function()
			{
				player.curPokemon.spawning(function()
				{
					enemy.moveTo(FlxPoint.weak(8, 0), 0.5, function()
					{
						enemy.curPokemon.spawning(makeSelectBox);
					});
				});
			});
		});
	}

	override public function update(elapsed:Float)
	{
		if (curTxtBox != null)
			curTxtBox.controls = controls;
		else
			mainBox.controls = controls;
		super.update(elapsed);
		if (controls.BACK.justPressed)
		{
			if (curTxtBox != null && !(Std.isOfType(curTxtBox, SelectBox)))
			{
				allBoxes.remove(curTxtBox, true);
				curTxtBox.destroy();
			}
		}
		if (curTxtBox != allBoxes.members[allBoxes.members.length - 1])
		{
			allBoxes.forEach(function(box)
			{
				box.controls = null;
			});
			curTxtBox = allBoxes.members[allBoxes.members.length - 1];
		}
		if (FlxG.keys.justPressed.R)
		{
			FlxG.resetState();
		}
		TurnManager.update(elapsed);
	}

	public function giveVictory()
	{
		if (!enemy.canContinue())
		{
			enemy.moveTo(FlxPoint.weak(-8, 0), 0.5, function()
			{
				mainBox.write(enemy.name + ": " + enemy.lostQuote, function()
				{
					player.money += enemy.loseReward;
					mainBox.write(enemy.name + " dio " + Std.string(enemy.loseReward) + "$");
				});
			});
		}
		else
			mainBox.write("¡" + player.name + " se quedo sin Pokémon!", function()
			{
				player.money -= player.loseReward;
				mainBox.write("¡" + player.name + " perdio el conocimiento!");
			});
	}

	public function makeSelectBox()
	{
		mainBox.erase();
		var actBox = new SelectBox(64, 96);
		addToBoxes(actBox);
	}

	function onSelectMove(move:Move)
	{
		TurnManager.newAttackTurn(player, enemy, move);
		onSelectInteraction();
	}

	public function onSelectInteraction()
	{
		enemy.selectInteraction(player);
		allBoxes.remove(curTxtBox, true);
		curTxtBox.destroy();
		clearBoxes();
		closeSubState();

		TurnManager.startTurn();
	}

	function clearBoxes()
	{
		while (allBoxes.members.length > 0)
		{
			final teBox = allBoxes.remove(allBoxes.members[0], true);
			teBox.destroy();
		}
	}

	function addToBoxes(txtBox:TextBox)
	{
		allBoxes.add(txtBox);
	}
}
