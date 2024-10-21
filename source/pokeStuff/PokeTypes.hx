package pokeStuff;

enum PokeType
{
	NORMAL;
	FIRE;
	WATER;
	GRASS;
	ELECTRIC;
	ICE;
	FIGHTING;
	POISON;
	GROUND;
	FLYING;
	PSYCHIC;
	BUG;
	ROCK;
	GHOST;
	DRAGON;
	BIRD;
}

class PokeTypes
{
	static var effectives:Map<PokeType, Map<PokeType, Float>> = [
		NORMAL => [ROCK => 0.5, GHOST => 0],
		FIRE => [
			WATER => 0.5,
			GRASS => 2,
			FIRE => 0.5,
			ICE => 2,
			BUG => 2,
			ROCK => 0.5,
			DRAGON => 0.5
		],
		WATER => [WATER => 0.5, GRASS => 0.5, FIRE => 2, GROUND => 2, ROCK => 2, DRAGON => 0.5],
		GRASS => [
			FIRE => 0.5,
			WATER => 2,
			GRASS => 0.5,
			POISON => 0.5,
			GROUND => 2,
			FLYING => 0.5,
			BUG => 0.5,
			ROCK => 2,
			DRAGON => 0.5
		],
		ELECTRIC => [
			ELECTRIC => 0.5,
			WATER => 2,
			GRASS => 0.5,
			GROUND => 0,
			FLYING => 2,
			DRAGON => 0.5
		],
		ICE => [ICE => 0.5, GRASS => 2, WATER => 0.5, FLYING => 2, DRAGON => 2],
		FIGHTING => [
			NORMAL => 2,
			ICE => 2,
			POISON => 0.5,
			FLYING => 0.5,
			PSYCHIC => 0.5,
			BUG => 0.5,
			ROCK => 2,
			GHOST => 0
		],
		POISON => [GRASS => 2, POISON => 0.5, GROUND => 0.5, BUG => 2, ROCK => 0.5, GHOST => 0.5],
		GROUND => [
			FIRE => 2,
			ELECTRIC => 2,
			GRASS => 0.5,
			POISON => 2,
			FLYING => 0,
			BUG => 0.5,
			ROCK => 2
		],
		FLYING => [ELECTRIC => 0.5, GRASS => 2, FIGHTING => 2, BUG => 2, ROCK => 0.5],
		PSYCHIC => [FIGHTING => 2, POISON => 2, PSYCHIC => 0.5],
		BUG => [
			FIRE => 0.5,
			GRASS => 2,
			FIGHTING => 0.5,
			POISON => 2,
			FLYING => 0.5,
			PSYCHIC => 2,
			GHOST => 0.5
		],
		ROCK => [FIRE => 2, ICE => 2, FIGHTING => 0.5, GROUND => 0.5, FLYING => 2, BUG => 2],
		GHOST => [GHOST => 2, NORMAL => 0],
		DRAGON => [DRAGON => 2]
	];

	public static function getMoveEffective(moveType:PokeType, pokemonType:Array<PokeType>):Float
	{
		var mult:Float = 1;
		if (effectives.exists(moveType))
		{
			for (type in pokemonType)
			{
				if (effectives.get(moveType).exists(type))
					mult *= effectives.get(moveType).get(type);
			}
		}

		return mult;
	}

	public static function getEffective(types1:Array<PokeType>, types2:Array<PokeType>):Float
	{
		var mult:Float = 1;
		for (type in types1)
		{
			if (!effectives.exists(type))
				continue;

			for (type2 in types2)
			{
				if (effectives.get(type).exists(type2))
					mult *= effectives.get(type).get(type2);
			}
		}
		return mult;
	}

	public static function getSTAB(moveType:PokeType, pokemonType:Array<PokeType>):Float
	{
		var stab:Float = 1;
		for (type in pokemonType)
		{
			if (moveType == type)
			{
				stab = 1.5;
				break;
			}
		}
		return stab;
	}

	public static function getType(type:String):PokeType
	{
		return switch (type.toLowerCase())
		{
			case "water":
				WATER;
			case "fire":
				FIRE;
			case "grass":
				GRASS;
			case "rock":
				ROCK;
			case "ground":
				GROUND;
			case "bug":
				BUG;
			case "ice":
				ICE;
			case "normal":
				NORMAL;
			case "flying":
				FLYING;
			case "electric":
				ELECTRIC;
			case "ghost":
				GHOST;
			case "poison":
				POISON;
			case "psychic":
				PSYCHIC;
			case "fighting":
				FIGHTING;
			case "dragon":
				DRAGON;
			default:
				BIRD;
		}
	}

	public static function translateType(?type:PokeType):String
	{
		return switch (type)
		{
			case WATER:
				"AGUA";
			case FIRE:
				"FUEGO";
			case GRASS:
				"PLANTA";
			case ROCK:
				"ROCA";
			case GROUND:
				"TIERRA";
			case BUG:
				"BICHO";
			case ICE:
				"HIELO";
			case NORMAL:
				"NORMAL";
			case FLYING:
				"VOLADOR";
			case ELECTRIC:
				"ELÉCTRIC";
			case GHOST:
				"FANTASMA";
			case POISON:
				"VENENO";
			case PSYCHIC:
				"PSÍQUICO";
			case FIGHTING:
				"LUCHA";
			case DRAGON:
				"DRAGÓN";
			default: "BIRD";
		}
	}
}
