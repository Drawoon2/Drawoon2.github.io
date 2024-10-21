package pokeStuff;

class StatuProblem
{
	public var status:String;

	public var affected:Pokemon;
	public var passTurns:Int = 0;
	public var probCure:Float = -1;
	public var minTurnForCure:Int = -1;
	public var probNotTurn:Float = 0;
	public var canFight:Bool = true;
	public var isCure:Bool = false;
	public var isVolatil:Bool = false;

	public var otherVars:Map<String, Dynamic> = [];

	public function new(affected:Pokemon, problem:String)
	{
		this.affected = affected;
		status = problem;
	}

	public function giveEffect():StatuProblem
	{
		switch (status)
		{
			case "PAR":
				affected.stats.speed *= .75;
				probNotTurn = .25;
			case "BRN":
				affected.stats.attack *= .5;
			case "SLP":
				minTurnForCure = FlxG.random.int(1, 7);
				probNotTurn = 1;
			case "DEB":
				canFight = false;
			case "DISABLE":
				isVolatil = true;
				var canAffectMoves = [];
				for (move in affected.movesList)
				{
					if (move.canUse)
						canAffectMoves.push(move);
				}
				final theMove = canAffectMoves[FlxG.random.int(0, canAffectMoves.length - 1)];
				theMove.isDisabled = true;
				otherVars.set("affectedMove", theMove);
				minTurnForCure = FlxG.random.int(1, 8);
			default:
				//
		}
		return this;
	}

	public function updateTurn():Int
	{
		var damage:Float = 0;
		if (passTurns > minTurnForCure && minTurnForCure > 0)
			isCure = true;

		if (FlxG.random.float(0, 1) <= probCure)
			isCure = true;
		if (!isCure)
		{
			passTurns++;
			if (status == "BPSN")
				damage = -affected.maxStats.hp * (passTurns + 1) / 16;

			if (status == "BRN" || status == "PSN")
				damage = -affected.maxStats.hp / 16;

			affected.stats.hp += damage;
		}
		return Std.int(damage);
	}

	public function onCure()
	{
		switch (status)
		{
			case "DISABLE":
				cast(otherVars.get("affectedMove"), Move).isDisabled = false;
			case "PAR":
				affected.stats.speed = affected.maxStats.speed;
			case "BRN":
				affected.stats.attack = affected.maxStats.attack;
		}
	}
}
