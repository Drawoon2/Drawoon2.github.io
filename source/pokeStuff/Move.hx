package pokeStuff;

import flixel.util.FlxStringUtil;
import pokeStuff.PokeTypes.PokeType;
import pokeStuff.Pokemon.Stats;

using StringTools;

typedef MoveData =
{
	var moveName:String;
	var power:Int;
	var accuary:Int;
	var type:String;
	var moveClass:String;
	var doContact:Bool;
	var priority:Int;
	var pp:Int;
	var ?multiProb:Array<Float>;
	var ?secondEffect:Array<SecondEffect>;
	var ?animName:String;
}

typedef SecondEffect =
{
	var effect:String;
	var prob:Float;
}

enum MoveClass
{
	FISIC;
	SPECIAL;
	STATE;
}

typedef EffectsData =
{
	var pokemon:Pokemon;
	var affect:String;
	var type:String;
	var ?lastStage:Int;
	var ?add:Int;
}

class Move
{
	public var realName:String = "COMBATE";
	public var fileName:String = "";
	public var type:PokeType = NORMAL;
	public var anim:String = "fisicMove1";

	public var curPP:Int;
	public var maxPP:Int;

	public var power:Int = 50;
	public var accuary:Int = -1;

	public var priority:Int = 0;

	public var doContact:Bool = true;
	public var moveClass:MoveClass = FISIC;
	public var multiHitProb:Array<Float> = [];
	public var effect:Array<SecondEffect>;
	public var canUse(get, default):Bool = true;
	public var isDisabled:Bool = false;

	public function new(moveName:String = "struggle")
	{
		fileName = moveName;
		var baseData = getMoveData(moveName);

		if (baseData != null)
		{
			realName = baseData.moveName;
			type = PokeTypes.getType(baseData.type);

			curPP = baseData.pp;
			maxPP = baseData.pp;

			power = baseData.power;
			accuary = baseData.accuary;

			priority = baseData.priority;
			doContact = baseData.doContact;
			moveClass = getClass(baseData.moveClass);
			anim = baseData.animName == null ? anim : baseData.animName;
			if (Std.isOfType(baseData.multiProb, Array))
				multiHitProb = baseData.multiProb;
			if (baseData.secondEffect != null)
			{
				effect = baseData.secondEffect;
			}
		}
	}

	public static function getClass(moveClass:String):MoveClass
	{
		return switch (moveClass)
		{
			case "special": SPECIAL;
			case "state": STATE;
			default:
				FISIC;
		}
	}

	private static function getMoveData(?name:String = ""):MoveData
	{
		var jsonContent:MoveData = Paths.data('moves/${name}');
		return jsonContent;
	}

	public static function attack(user:Pokemon, enemy:Pokemon, move:Move):Map<String, Dynamic>
	{
		move.curPP--;
		var move_things:Map<String, Dynamic> = [];
		var criticalMult:Float = 1;
		var criticalUmbral:Float = user.stats.speed / 2;

		var random = FlxG.random.int(217, 255) / 255;

		var wasHit:Bool = true;
		if (move.accuary != -1)
			wasHit = FlxG.random.int(0, 255) < ((move.accuary * user.stats.accuary * enemy.stats.evasion) / 100) * 255;

		var hitsDamage:Array<Int> = [];
		var allGiveEffects:Array<EffectsData> = [];

		if (wasHit)
		{
			if (move.moveClass != STATE)
			{
				var repeatTimes:Int = 0;
				if (move.multiHitProb.length > 0)
				{
					var prob:Float = FlxG.random.float(0, 100);
					trace(prob);
					for (hitProb in move.multiHitProb)
					{
						trace(hitProb);
						if (hitProb >= prob)
						{
							repeatTimes++;
						}
						else
							break;
					}
				}
				else
					repeatTimes = 1;

				var STAB:Float = PokeTypes.getSTAB(move.type, user.types);
				var effective:Float = PokeTypes.getMoveEffective(move.type, enemy.types);
				var isCritical:Bool = FlxG.random.int(0, 255) <= criticalUmbral;
				if (isCritical)
					criticalMult = (user.level * 2 + 5) / (user.level + 5);

				var userStats:Stats = isCritical ? user.maxStats : user.stats;
				var targetStats:Stats = isCritical ? enemy.maxStats : enemy.stats;

				for (i in 0...repeatTimes)
				{
					var damage:Float = 2 * user.level * criticalMult / 5 + 2;
					if (criticalMult != 1)
						criticalMult = 1;
					damage *= STAB;
					if (move.moveClass == SPECIAL)
						damage *= (move.power * (userStats.special / targetStats.special));
					else
						damage *= (move.power * (userStats.attack / targetStats.defense));

					damage = damage / 50 + 2;
					if (damage < 1)
						damage = 1;
					else
						damage *= random;

					damage *= effective;
					enemy.stats.hp -= Std.int(damage);
					hitsDamage.push(Std.int(damage));
					if (enemy.stats.hp <= 0)
						break;
				}
				move_things.set("hitsDamage", hitsDamage);
				move_things.set("effective", effective);
				move_things.set("isCritical", isCritical);
				move_things.set("isMultiHit", move.multiHitProb.length > 0);
			}
			else
			{
				move_things.set("hitsDamage", []);
				move_things.set("effective", 1);
				move_things.set("isCritical", false);
				move_things.set("isMultiHit", false);
			}

			if (move.effect != null)
			{
				var effectProb = FlxG.random.float(0, 100);
				for (effectData in move.effect)
				{
					if (effectProb <= effectData.prob)
					{
						var effects = effectData.effect.split("/");
						for (effect in effects)
						{
							var newEffectData = effect.split(".");
							var problemData:EffectsData = {
								"pokemon": null,
								"affect": "",
								"type": ""
							};
							var poke:Pokemon;
							poke = switch (newEffectData[0].toLowerCase())
							{
								case "user":
									user;
								default:
									enemy;
							}
							problemData.pokemon = poke;
							switch (newEffectData[1])
							{
								case "attack" | "defense" | "speed" | "special" | "evasion" | "accuary":
									problemData.type = "changeStage";
									var set:Float = 0;
									var lastStage = Reflect.field(poke.statsStages, newEffectData[1]);
									set = lastStage + Std.parseFloat(newEffectData[2]);
									if (set > 6)
										set = 6;
									else if (set < -6)
										set = -6;
									Reflect.setField(poke.statsStages, newEffectData[1], set);
									poke.updateStat(newEffectData[1]);
									problemData.affect = newEffectData[1];
									problemData.lastStage = Std.int(lastStage);
									problemData.add = Std.parseInt(newEffectData[2]);
								default:
									var statuProblem = new StatuProblem(poke, newEffectData[1]);
									final succed = poke.addEffect(statuProblem);
									problemData.type = statuProblem.isVolatil ? "volatilStatus" : "noVolatilStatus";
									problemData.affect = newEffectData[1];
									if (move.moveClass == STATE && succed)
									{
										wasHit = false;
									}
							}
							allGiveEffects.push(problemData);
						}
					}
				}
			}
			move_things.set("effects", allGiveEffects);
		}

		move_things.set("hasMiss", !wasHit);

		return move_things;
	}

	function get_canUse()
	{
		return curPP > 0 && !isDisabled;
	}

	public static function isExist(name:String):Bool
	{
		return Paths.data('moves/${name}') != null;
	}

	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("name", realName),
			LabelValuePair.weak("FilesName", fileName),
			LabelValuePair.weak("type", type),

		]);
	}
}
