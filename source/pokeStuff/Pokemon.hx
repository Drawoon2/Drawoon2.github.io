package pokeStuff;

import Utils.Direction;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxStringUtil;
import pokeStuff.PokeTypes.PokeType;

typedef PokemonData =
{
	var name:String;
	var image:String;
	var menuImage:String;
	var types:Array<String>;
	var stats:StatsData;
	var levels:Array<MoveLevel>;
}

typedef StatsData =
{
	var attack:Int;
	var defense:Int;
	var hp:Int;
	var special:Int;
	var speed:Int;
}

typedef MoveLevel =
{
	var level:Int;
	var move:String;
}

class Pokemon extends PokeSprite
{
	public static final DEFAULT_POKEMON:String = "pikachu";
	public static final DEFAULT_LEVEL:Int = 50;

	public var trainer:Trainer;
	public var name:String = "MISSINGNO";
	public var menuImage:String = "default";
	public var direction:Direction = BACK;

	public var volatilEffects:Array<StatuProblem> = [];
	public var noVolatilEffects:StatuProblem = null;
	public var haveNoVolatil:Bool = false;

	public var level:Int;

	public var types:Array<PokeType> = [];

	var defaultStats:Stats; // Base Stats

	public var statsStages:Stats = new Stats(); // reduction/increments stats stages

	public var maxStats:Stats; // default stats without changes
	public var visibleHealth(default, set):Int = 0;
	public var stats:Stats; // Real Stats

	public var ivs:Stats;

	public var evs:Stats;

	var baseData:PokemonData; // Base Pokemon Data

	public var movesList:Array<Move> = [];
	public var usedMoves:Array<Move> = [];

	var haveFight = false;

	public var canContinue(get, null) = true;
	public var hpPerc(get, null):Float = 1;

	function get_hpPerc()
	{
		return stats.hp / maxStats.hp;
	}

	public function new(x:Float = 0, y:Float = 0, name:String = "", ?isFront = false)
	{
		super(x, y);
		visible = false;
		baseData = getBaseStat(name);
		defaultStats = new Stats(baseData.stats);
		this.name = baseData.name;
		menuImage = baseData.menuImage;
		loadGraphic(getImagePath(isFront));
		direction = isFront ? FRONT : BACK;
		loadStats();
		var canLearnMove:Array<Move> = [];

		for (levelMove in baseData.levels)
		{
			if (levelMove == null)
				continue;
			if (!Move.isExist(levelMove.move))
				continue;
			if (canLearnMove.contains(new Move(levelMove.move)))
				continue;
			if (levelMove.level <= level)
				canLearnMove.push(new Move(levelMove.move));
		}
		if (FlxG.random.int(0, 100) < 25)
			canLearnMove.push(new Move("gun"));
		if (canLearnMove.length > 0)
		{
			final haveMoves:Array<Int> = [];
			for (i in 0...4)
			{
				if (canLearnMove.length - 1 < i)
					break;

				final random:Int = FlxG.random.int(0, canLearnMove.length - 1, haveMoves);
				trace(canLearnMove[random]);
				haveMoves.push(random);
				movesList.push(canLearnMove[random]);
			}
		}
		else
			movesList.push(new Move());
	}

	override function spawning(onComplete:() -> Void)
	{
		if (!haveFight)
		{
			visible = true;
			super.spawning(onComplete);
			haveFight = true;
		}
		else
		{
			if (direction == BACK)
			{
				moveTo(FlxPoint.weak(width / 8 + 1, 0), animationTime.get("spawning"), onComplete);
			}
			else
			{
				moveTo(FlxPoint.weak(-width / 8, 0), animationTime.get("spawning"), onComplete);
			}
		}
	}

	public function comeBack(onComplete:() -> Void)
	{
		if (direction == BACK)
		{
			moveTo(FlxPoint.weak(-width / 8 - 1, 0), animationTime.get("comeBack"), onComplete);
		}
		else
		{
			moveTo(FlxPoint.weak(width / 8, 0), animationTime.get("comeBack"), onComplete);
		}
	}

	public function addEffect(effect:StatuProblem):Bool
	{
		if (effect.isVolatil)
		{
			for (curEffects in volatilEffects)
			{
				if (curEffects.status == effect.status)
					return false;
			}
			volatilEffects.push(effect);
		}
		else
		{
			if (noVolatilEffects != null)
				return false;
			noVolatilEffects = effect;
		}
		effect.giveEffect();
		return true;
	}

	public function removeEffect(effect:StatuProblem)
	{
		if (effect.isVolatil)
		{
			volatilEffects.remove(effect);
		}
		else
		{
			noVolatilEffects = null;
		}
		effect.onCure();
	}

	public function updateStat(stat:String)
	{
		var curStage:Float = Reflect.field(statsStages, stat);
		var maxStat:Float = Reflect.field(maxStats, stat);
		Reflect.setField(stats, stat, maxStat * Stats.getStageMult(curStage));
	}

	public function resetStats()
	{
		volatilEffects = [];
		stats.copy(maxStats);
		statsStages = new Stats();
		if (noVolatilEffects != null)
		{
			noVolatilEffects.giveEffect();
		}
	}

	function get_canContinue():Bool
	{
		return (noVolatilEffects == null || noVolatilEffects.canFight);
	}

	function loadStats():Void
	{
		for (type in baseData.types)
		{
			types.push(PokeTypes.getType(type));
		}

		level = DEFAULT_LEVEL + FlxG.random.int(-2, 2);
		ivs = new Stats().generatedIVS();
		evs = new Stats();
		maxStats = new Stats().generatedStats(level, defaultStats, ivs, evs);

		stats = maxStats.clone();
		visibleHealth = Std.int(stats.hp);
		trace(maxStats);
	}

	function set_visibleHealth(value:Int)
	{
		if (value <= 0)
		{
			value = 0;
			noVolatilEffects = new StatuProblem(this, "DEB").giveEffect();
		}

		return visibleHealth = value;
	}

	function getImagePath(front:Bool):String
	{
		var prefix = front ? "fronts/" : "backs/";
		return Paths.images('pokemons/${prefix + baseData.image}');
	}

	static function getBaseStat(?name:String = ""):PokemonData
	{
		var jsonContent:PokemonData = Paths.data('pokemons/${name}');
		if (jsonContent == null)
			jsonContent = Paths.data('pokemons/${DEFAULT_POKEMON}');
		return jsonContent;
	}
}

class Stats
{
	public var hp(default, set):Float = 0;
	public var attack:Float = 0;
	public var defense:Float = 0;
	public var special:Float = 0;
	public var speed:Float = 0;
	public var accuary:Float = 1;
	public var evasion:Float = 1;

	static var dictionary:Array<String> = ['hp', 'attack', 'defense', 'speed', 'special'];

	public function new(?statsData:StatsData)
	{
		if (statsData != null)
		{
			hp = statsData.hp;
			attack = statsData.attack;
			defense = statsData.defense;
			special = statsData.special;
			speed = statsData.speed;
		}
	}

	public static function getStageMult(stage:Float = 0):Float
	{
		var multiple:Int = 100;

		switch (Std.int(stage))
		{
			case 6:
				multiple = 400;
			case 5:
				multiple = 350;
			case 4:
				multiple = 300;
			case 3:
				multiple = 250;
			case 2:
				multiple = 200;
			case 1:
				multiple = 150;
			case -1:
				multiple = 66;
			case -2:
				multiple = 50;
			case -3:
				multiple = 40;
			case -4:
				multiple = 33;
			case -5:
				multiple = 28;
			case -6:
				multiple = 25;
			default:
				multiple = 100;
		}
		var result:Float = multiple / 100;
		return result;
	}

	function set_hp(value:Float)
	{
		if (value < 0)
			value = 0;
		return hp = value;
	}

	public function generatedIVS():Stats
	{
		for (stat in dictionary)
		{
			var statInt:Float = 0;
			var ivsForHP:Float = 0;
			var newIvs = FlxG.random.int(0, 15);
			switch (stat)
			{
				case "attack":
					attack = statInt = newIvs;
					ivsForHP = 8;
				case "defense":
					defense = statInt = newIvs;
					ivsForHP = 4;
				case "speed":
					speed = statInt = newIvs;
					ivsForHP = 2;
				case "special":
					special = statInt = newIvs;
					ivsForHP = 1;
			}
			if (FlxMath.isOdd(statInt))
				hp += ivsForHP;
		}
		return this;
	}

	public function clone():Stats
	{
		var newClone:Stats = new Stats();
		newClone.hp = hp;
		newClone.attack = attack;
		newClone.defense = defense;
		newClone.special = special;
		newClone.speed = speed;
		return newClone;
	}

	public function copy(stats:Stats, ?resetHP:Bool = false)
	{
		if (resetHP)
			hp = stats.hp;
		attack = stats.attack;
		defense = stats.defense;
		special = stats.special;
		speed = stats.speed;
	}

	public function generatedStats(level:Int, baseStats:Stats, ivs:Stats, evs:Stats):Stats
	{
		for (stat in dictionary)
		{
			var curBase:Float = Reflect.field(baseStats, stat);
			var curIvs:Float = Reflect.field(ivs, stat);
			var curEvs:Float = Reflect.field(evs, stat);

			var formula = Math.floor((((curBase + curIvs) * 2 + Math.floor(Math.sqrt(curEvs) / 4)) * level) / 100);
			if (stat == "hp")
				formula += level + 10;
			else
				formula += 5;

			Reflect.setField(this, stat, formula);
		}
		return this;
	}

	public static function traslateStat(stat:String):String
	{
		return switch (stat.toLowerCase())
		{
			case "attack":
				"ATAQUE";
			case "defense":
				"DEFENSA";
			case "special":
				"ESPECIAL";
			case "speed":
				"VELOCIDAD";
			case "accuary":
				"PRECISIÓN";
			case "evasion":
				"EVASIÓN";
			default:
				"UNKNOWN";
		}
	}

	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("hp", hp),
			LabelValuePair.weak("attack", attack),
			LabelValuePair.weak("defense", defense),
			LabelValuePair.weak("speed", speed),
			LabelValuePair.weak("special", special)
		]);
	}
}
