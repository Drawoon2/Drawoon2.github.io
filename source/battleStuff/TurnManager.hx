package battleStuff;

import flixel.math.FlxMath;
import pokeStuff.*;
import pokeStuff.Move.EffectsData;
import pokeStuff.Pokemon.Stats;
import subStates.PokemonSubState;

using StringTools;

enum Interactions
{
	ATTACK;
	CHANGES;
	ITEM;
	ESCAPE;
}

class TurnManager
{
	static var curTurn:Int = 0;
	static var defaultPriority:Map<Interactions, Int> = [CHANGES => 2, ITEM => 2, ESCAPE => 2, ATTACK => 0];
	static var turnsParts:Array<TurnManager> = [];
	static var turnSteps:Array<TurnStep> = [];
	static var turnStarted:Bool = false;

	public var priority:Int = 0;
	public var isComplete:Bool = false;
	public var repeat:Int = 1;
	public var user:Trainer;
	public var enemy:Trainer;

	public var extra:Map<String, Dynamic> = [];

	public var interaction:Interactions;

	public static var battle:PlayState;

	public function new(interaction:Interactions, user:Trainer, ?other:Dynamic, ?enemy:Trainer)
	{
		this.interaction = interaction;
		this.user = user;
		this.enemy = enemy;

		switch (interaction)
		{
			case ATTACK:
				extra.set("move", other);
				priority += other.priority;
			case CHANGES:
				extra.set("newPoke", other);
			case ITEM:
				extra.set("item", other);
			default:
				//
		}
		turnsParts.push(this);
	}

	public static function update(elapsed:Float)
	{
		if (turnStarted)
		{
			var curTurnSteps = turnSteps[0];
			if (!curTurnSteps.hasStart)
			{
				curTurnSteps.startStep();
			}
			else
				curTurnSteps.updateStep(elapsed);
			if (curTurnSteps.isComplete)
			{
				turnSteps.shift();
				if (turnSteps.length < 1)
				{
					curTurn++;
					turnStarted = false;
					trace("Cur turn: " + curTurn);

					if (battle.hasWinner)
					{
						battle.giveVictory();
					}
					else
						battle.makeSelectBox();
				}
			}
		}
	}

	var isLoadedStart = false;
	var reduceHealth:Bool = false;
	var time:Float = 0;
	var doTurn:Bool = true;

	public static function newAttackTurn(user:Trainer, enemy:Trainer, move:Move):TurnManager
	{
		return new TurnManager(ATTACK, user, move, enemy);
	}

	public static function newChangesTurn(user:Trainer, newPoke:Pokemon):TurnManager
	{
		return new TurnManager(CHANGES, user, newPoke);
	}

	public static function newItemTurn(user:Trainer, object):TurnManager
	{
		return new TurnManager(ITEM, user, object);
	}

	public static function startTurn():Void
	{
		turnsParts.sort(function(manager1, manager2)
		{
			// Action Priority
			if (defaultPriority.get(manager1.interaction) < defaultPriority.get(manager2.interaction))
				return 1;
			else if (defaultPriority.get(manager1.interaction) > defaultPriority.get(manager2.interaction))
				return -1;
			// Other priority type
			if (manager1.priority < manager2.priority)
				return 1;
			else if (manager1.priority > manager2.priority)
				return -1;
			// Speed priority
			if (manager1.user.curPokemon.stats.speed < manager2.user.curPokemon.stats.speed)
				return 1;
			else if (manager1.user.curPokemon.stats.speed > manager2.user.curPokemon.stats.speed)
				return -1;
			// last option
			return FlxG.random.int(-1, 1, [0]);
		});

		loadSteps();
		turnStarted = true;
	}

	public static function loadSteps()
	{
		turnSteps = [];
		var isFainteds:Bool = false;
		while (turnsParts.length > 0)
		{
			var turnPart = turnsParts.shift();
			if (isFainteds)
				continue;
			switch (turnPart.interaction)
			{
				case ATTACK:
					final move = turnPart.extra.get("move");
					final userPoke:Pokemon = turnPart.user.curPokemon;
					final enemyPoke:Pokemon = turnPart.enemy.curPokemon;
					if (canTurnEffect(userPoke))
					{
						var attack = Move.attack(userPoke, enemyPoke, move);
						var useStep = new TurnStep("use", userPoke);
						useStep.setVar("move", move);
						turnSteps.push(useStep);
						if (attack.get("hasMiss"))
						{
							turnSteps.push(new TurnStep("miss", userPoke));
						}
						else
						{
							userPoke.usedMoves.push(move);
							var hitsDamage:Array<Int> = attack.get("hitsDamage");
							if (hitsDamage.length > 0)
							{
								for (damage in hitsDamage)
								{
									var hitStep = new TurnStep("hit", userPoke);
									hitStep.setVar("move", move);
									hitStep.setVar("enemy", enemyPoke);
									turnSteps.push(hitStep);
									var updateHealth = new TurnStep("health", enemyPoke);
									updateHealth.setVar("add", -damage);
									turnSteps.push(updateHealth);
								}
							}
							else
							{
								var hitStep = new TurnStep("hit", userPoke);
								hitStep.setVar("move", move);
								hitStep.setVar("enemy", enemyPoke);
								turnSteps.push(hitStep);
							}

							if (attack.get("isMultiHit"))
							{
								var multiHitStep = new TurnStep("multiHit", userPoke);
								multiHitStep.setVar("times", attack.get("hitsDamage").length);
								turnSteps.push(multiHitStep);
							}
							if (attack.get("effects").length > 0)
							{
								var effects:Array<EffectsData> = attack.get("effects");
								for (effectData in effects)
								{
									var effectStep = new TurnStep(effectData.type, effectData.pokemon);
									effectStep.setVar("data", effectData);
									effectStep.setVar("type", "give");
									turnSteps.push(effectStep);
								}
							}
							if (attack.get("effective") != 1)
							{
								var effectiveStep = new TurnStep("effective", userPoke);
								effectiveStep.setVar("effective", attack.get("effective"));
								effectiveStep.setVar("enemy", enemyPoke);
								turnSteps.push(effectiveStep);
							}
							if (attack.get("isCritical"))
							{
								turnSteps.push(new TurnStep("critical", userPoke));
							}

							isFainteds = comprobeFainted(enemyPoke) || comprobeFainted(userPoke);
						}
					}
				case CHANGES:
					var changeStep = new TurnStep("change", turnPart.user.curPokemon);
					changeStep.setVar("newPoke", turnPart.extra.get("newPoke"));
					turnSteps.push(changeStep);
					turnPart.user.curPokemon = turnPart.extra.get("newPoke");
				default:
					trace("Unknown TurnPart");
			}
		}
		if (!isFainteds)
		{
			updateTurnEffects(battle.player.curPokemon);
			updateTurnEffects(battle.enemy.curPokemon);
		}
	}

	public static function comprobeFainted(poke:Pokemon):Bool
	{
		if (poke.stats.hp == 0)
		{
			turnSteps.push(new TurnStep("fainted", poke));
			return true;
		}
		return false;
	}

	public static function canTurnEffect(poke:Pokemon):Bool
	{
		var random:Float = FlxG.random.float(0, 1);
		var stepAffect = new TurnStep("affect", poke);

		if (poke.noVolatilEffects != null)
		{
			var prob:Float = poke.noVolatilEffects.probNotTurn;
			if (random <= prob)
			{
				stepAffect.setVar("effect", poke.noVolatilEffects.status);
				turnSteps.push(stepAffect);
				return false;
			}
		}
		for (effects in poke.volatilEffects)
		{
			var prob:Float = effects.probNotTurn;
			if (random <= prob)
			{
				stepAffect.setVar("effect", effects.status);
				turnSteps.push(stepAffect);
				return false;
			}
		}
		return true;
	}

	public static function updateTurnEffects(poke:Pokemon)
	{
		if (poke.noVolatilEffects != null)
		{
			updateEffect(poke.noVolatilEffects, poke);
		}

		for (effects in poke.volatilEffects)
		{
			updateEffect(effects, poke);
		}
		comprobeFainted(poke);
	}

	static function updateEffect(effect:StatuProblem, poke:Pokemon)
	{
		final stepAffect = new TurnStep("affect", poke);
		var add:Int = effect.updateTurn();
		if (add != 0)
		{
			stepAffect.setVar("effect", effect.status);
			turnSteps.push(stepAffect);
			var updateHealth = new TurnStep("health", poke);
			updateHealth.setVar("add", add);
			turnSteps.push(updateHealth);
		}
		else if (effect.isCure)
		{
			poke.removeEffect(effect);
			final stepCure = new TurnStep("cureEffect", poke);
			stepCure.setVar("effect", effect.status);
			turnSteps.push(stepCure);
		}
	}
}

class TurnStep
{
	public var interaction:String = "unknown";
	public var pokemon:Pokemon;
	public var hasStart:Bool = false;
	public var isComplete:Bool = false;
	public var vars:Map<String, Any> = [];

	public function new(interaction:String, poke:Pokemon)
	{
		this.interaction = interaction;
		pokemon = poke;
	}

	public function getVar(name:String):Any
	{
		if (vars.exists(name))
			return vars.get(name);

		return null;
	}

	public function setVar(name:String, newVar:Any)
		vars.set(name, newVar);

	public function existVar(name:String)
		return vars.exists(name);

	public function startStep()
	{
		hasStart = true;
		trace(interaction);
		switch (interaction)
		{
			case "hit":
				TurnManager.battle.effects.playMove(pokemon, getVar("enemy"), getVar("move"), complete);
			case "health":
				var add:Int = getVar("add");
				lastHealth = pokemon.visibleHealth;
				newHealth = pokemon.visibleHealth + add;
			case "noVolatilStatus" | "volatilStatus":
				var effectData:EffectsData = getVar("data");
				TurnManager.battle.mainBox.write(getStatusText("give", effectData.affect), function()
				{
					if (interaction == "noVolatilStatus")
						pokemon.haveNoVolatil = true;

					complete();
				});
			case "affect":
				TurnManager.battle.mainBox.write(getStatusText("affect", getVar("effect")), function()
				{
					complete();
				});
			case "cureEffect":
				TurnManager.battle.mainBox.write(getStatusText("lose", getVar("effect")), function()
				{
					complete();
				});
			case "changeStage":
				var changeData:EffectsData = getVar("data");
				var text:String = "";
				if ((changeData.lastStage >= 6) || (changeData.lastStage <= -6))
					text = "¡No pasó nada!";
				else if (changeData.add == 1)
					text = "¡{stat} de\n{user}\ncreció!";
				else if (changeData.add >= 1)
					text = "¡{stat}\nde {user} a aumentado mucho!";
				else if (changeData.add == -1)
					text = "¡{stat} de\n{user}\nbajo!";
				else if (changeData.add >= 1)
					text = "¡{stat}\nde {user} se a reducido mucho!";
				TurnManager.battle.mainBox.write(loadText(text), complete);
			case "effective":
				TurnManager.battle.mainBox.write(getEffectiveText(getVar("effective")), complete);
			case "change":
				changePoke(getVar("newPoke"));
			case "fainted":
				TurnManager.battle.mainBox.write(loadText("fainted"), function()
				{
					pokemon.haveNoVolatil = true;
					pokemon.faiting(function()
					{
						if (pokemon.trainer.canContinue())
						{
							if (pokemon.trainer.isPlayer)
							{
								var pokeSubstate = new PokemonSubState(pokemon.trainer, true, true);
								pokeSubstate.controls = TurnManager.battle.controls;
								pokeSubstate.onSelect = function(poke:Pokemon)
								{
									changePoke(poke, true);
								}
								TurnManager.battle.openSubState(pokeSubstate);
							}
							else
							{
								changePoke(pokemon.trainer.choosePokemon(), true);
							}
						}
						else
						{
							complete();
							TurnManager.battle.hasWinner = true;
						}
					});
				});
			default:
				if (texts.exists(interaction))
				{
					TurnManager.battle.mainBox.write(loadText(interaction), complete);
				}
				else
				{
					complete();
				}
		}
	}

	var newPoke:Pokemon;

	function changePoke(newPoke:Pokemon, ?afterFate:Bool = false)
	{
		trace("change");
		this.newPoke = newPoke;
		pokemon.trainer.curPokemon = newPoke;

		var func = function()
		{
			TurnManager.battle.mainBox.write(loadText("Ve {newPoke}"), function()
			{
				pokemon.trainer.updateHUD();
				newPoke.spawning(complete);
			});
		}
		if (afterFate)
			func();
		else
			TurnManager.battle.mainBox.write(loadText("Vuelve {user}"), function()
			{
				pokemon.comeBack(func);
			});
	}

	public function complete()
		isComplete = true;

	var newHealth:Int = 0;
	var lastHealth:Int = 0;
	var waitTime:Float = 0.2;
	var totalElapsed:Float = 0;
	var startReduction:Bool = false;

	public function updateStep(elapsed:Float)
	{
		totalElapsed += elapsed;
		if (interaction == "health")
		{
			if (totalElapsed <= waitTime)
			{
				pokemon.visibleHealth = Std.int(FlxMath.lerp(lastHealth, newHealth, totalElapsed / waitTime));
			}
			else
			{
				pokemon.visibleHealth = newHealth;
				complete();
			}
		}
	}

	function getStatusText(type:String, problem:String):String
	{
		return loadText(problem + type);
	}

	function getEffectiveText(mult:Float = 1):String
	{
		if (mult == 0)
		{
			return loadText("notAffect");
		}
		else if (mult < 1)
		{
			return loadText("notEffective");
		}
		else if (mult > 1)
		{
			return loadText("effective");
		}
		return null;
	}

	static var texts:Map<String, String> = [
		"critical" => "¡Ataque crítico!",
		"effective" => "¡Es súper\nefectivo!",
		"notEffective" => "No es muy\nefectivo...",
		"notAffect" => "No afecta a {enemy}",
		"miss" => "Pero, ¡falló!",
		"use" => "¡{user}\nusó {move}!",
		"multiHit" => "¡Golpeo al enemigo {times} veces!",
		"fainted" => "¡{user} a sido\ndebilitado!",
		"PARgive" => "¡{user}\nfue paralizado!\n¡quizas no ataque!",
		"PARaffect" => "¡{user} esta paralizado!",
		"PARlose" => "¡{user} ya no esta paralizado!",
		"PSNgive" => "¡{user}\nfue envenenado!",
		"PSNaffect" => "¡{user}\nes dañado por\n el veneno!",
		"PSNlose" => "¡{user} ya no esta paralizado!",
		"BRNgive" => "¡{user} fue quemado!",
		"BRNaffect" => "¡{user} fue herido por quemaduras!",
		"BRNlose" => "¡{user} ya no esta quemado!",
		"CONFUSIONgive" => "¡{user}\nse hizo un lío!",
		"CONFUSIONaffect" => "¡{user}\n esta confuso!",
		"CONFUSIONhurt" => "¡Tan confuso\nesta que se\nhiere a si mismo!",
		"CONFUSIONlose" => "¡{user}\n ya no esta confuso!",
	];

	/*
		--pregunta despues de DEB contra salvaje
		¿Uso otro\nPOKEMON?

	 */
	function loadText(type:String):String
	{
		TurnManager.battle.mainBox.erase();
		var string:String = texts.exists(type) ? texts.get(type) : type;
		string = string.replace("{user}", pokemon.trainer.teamPrefix + pokemon.name);
		if (existVar("enemy"))
		{
			var enemy:Pokemon = getVar("enemy");
			string = string.replace("{enemy}", enemy.trainer.teamPrefix + enemy.name);
		}

		if (existVar("move"))
		{
			var move:Move = getVar("move");
			string = string.replace("{move}", move.realName);
		}

		if (existVar("times"))
		{
			var times:Int = getVar("times");
			string = string.replace("{times}", Std.string(times));
			if (times <= 1)
				string = string.replace("veces", "vez");
		}
		if (existVar("data"))
		{
			var changeData:EffectsData = getVar("data");
			string = string.replace("{stat}", Stats.traslateStat(changeData.affect));
		}
		if (newPoke != null)
		{
			string = string.replace("{newPoke}", newPoke.trainer.teamPrefix + newPoke.name);
		}
		return string;
	}
}
