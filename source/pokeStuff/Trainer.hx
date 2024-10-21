package pokeStuff;

import battleStuff.BattleHUD;
import battleStuff.TurnManager;

typedef TrainerData =
{
	var trainerName:String;
	var trainerImage:String;
	var difficulty:String;
	var pokemons:Array<String>;
	var inventory:Array<String>;
	var loseDialogue:String;
	var trainerType:String;
}

typedef TrainersType =
{
	var typeTrainer:String;
	var baseMoney:Int;
}

class Trainer extends PokeSprite
{
	static final DEFAULT_TRAINER:String = "player";

	public var name:String = "";
	public var pathName:String = "";
	public var team:Array<Pokemon> = [];
	public var inventory:Array<String> = [];
	public var lostQuote:String = "...";
	public var money:Int = 999;
	public var loseReward:Int = 0;

	public var teamPrefix:String = "";
	public var curPokemon(default, set):Pokemon;
	public var baseData:TrainerData;
	public var isPlayer:Bool = false;

	public var battleHUD:BattleHUD;

	static var trainersData:Map<String, TrainersType> = [];

	public function new(x:Float = 0, y:Float = 0, name:String, ?isFront = false)
	{
		super(x, y);
		pathName = name == null ? DEFAULT_TRAINER : name;

		baseData = getBaseData(pathName);
		loadGraphic(Paths.images("trainers/" + (isFront ? "fronts/" : "backs/") + baseData.trainerImage));

		this.name = baseData.trainerName;
		lostQuote = baseData.loseDialogue;
		for (pokemon in baseData.pokemons)
		{
			var newPoke:Pokemon = new Pokemon(x, y, pokemon, isFront);
			newPoke.trainer = this;
			team.push(newPoke);
		}
		var baseMoney = 300;
		if (trainersData.exists(baseData.trainerType))
		{
			baseMoney = trainersData.get(baseData.trainerType).baseMoney;
		}
		else if (this.name == "player")
		{
			baseMoney = 120;
		}
		loseReward = baseMoney * team[team.length - 1].level;
		curPokemon = team[0];
	}

	public function canContinue():Bool
	{
		for (poke in team)
		{
			if (poke.canContinue)
				return true;
		}
		return false;
	}

	public function updateHUD()
	{
		battleHUD.pokemon = curPokemon;
	}

	function set_curPokemon(poke:Pokemon)
	{
		if (curPokemon != null)
			curPokemon.resetStats();
		return curPokemon = poke;
	}

	static function getBaseData(?name:String = ""):TrainerData
	{
		var jsonContent:TrainerData = Paths.data('trainers/${name}');
		if (jsonContent == null)
			jsonContent = Paths.data('trainers/${DEFAULT_TRAINER}');
		return jsonContent;
	}

	public static function getTrainersData()
	{
		final jsonContent:Array<TrainersType> = Paths.data('trainers/baseTrainersData');
		for (data in jsonContent)
		{
			trainersData.set(data.typeTrainer, data);
		}
	}

	public function selectInteraction(opponent:Trainer)
	{
		if (PokeTypes.getEffective(curPokemon.types, opponent.curPokemon.types) > 1
			|| PokeTypes.getEffective(opponent.curPokemon.types, curPokemon.types) <= 1)
		{
			TurnManager.newAttackTurn(this, opponent, chooseMove(opponent.curPokemon));
			return;
		}

		if (curPokemon.hpPerc < 0.2 && opponent.curPokemon.hpPerc > 0.75)
		{
			TurnManager.newChangesTurn(this, choosePokemon(opponent.curPokemon));
			return;
		}

		TurnManager.newAttackTurn(this, opponent, chooseMove(opponent.curPokemon));
	}

	public function chooseMove(opponent:Pokemon):Move
	{
		var move:Move = curPokemon.movesList[0];
		for (moves in curPokemon.movesList)
		{
			if (!moves.canUse)
				continue;
			if (opponent.stats.hp < 15 && moves.priority > move.priority)
			{
				move = moves;
			}
			if (PokeTypes.getMoveEffective(moves.type, opponent.types) > 1)
			{
				move = moves;
			}
			if (move.power < moves.power)
			{
				move = moves;
			}
		}
		return move;
	}

	public function choosePokemon(?opponent:Pokemon = null):Pokemon
	{
		var newPoke:Pokemon = null;
		for (poke in team)
		{
			if (!poke.canContinue || poke == curPokemon)
				continue;

			if (opponent != null && PokeTypes.getEffective(poke.types, opponent.types) > 1)
			{
				newPoke = poke;
			}
			if (newPoke == null)
				newPoke = poke;
		}
		return newPoke;
	}
}
