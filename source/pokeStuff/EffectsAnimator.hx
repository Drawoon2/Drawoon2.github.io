package pokeStuff;

import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;

typedef AnimData = Array<AnimFuncData>;

typedef AnimFuncData =
{
	var funcName:String;
	var ?isUser:Bool;
	var ?pos:Array<Float>;
	var ?duration:Float;
	var ?vars:Array<Float>;
}

class EffectsAnimator extends FlxTypedGroup<FlxBasic>
{
	public var onComplete:Void->Void;
	public var user:Pokemon;
	public var target:Pokemon;

	var animation:AnimData;
	var playing:Bool = false;

	public function new()
	{
		super();
	}

	public function playMove(user:Pokemon, target:Pokemon, move:Move, onComplete:Void->Void)
	{
		this.onComplete = onComplete;
		this.user = user;
		this.target = target;

		playing = true;
		if (move.anim != null)
		{
			animation = Paths.data("moves/anims/" + move.anim);
		}
		else
			finish();
	}

	function finish()
	{
		playing = false;
		animation = null;
		if (onComplete != null)
		{
			onComplete();
			onComplete = null;
		}
	}

	var hasFinishStep = true;

	function onEndStep()
	{
		animation.shift();
		hasFinishStep = true;
	}

	override function update(elapsed:Float)
	{
		if (playing)
		{
			if (animation != null)
			{
				if (hasFinishStep)
				{
					if (animation.length > 0)
					{
						hasFinishStep = false;
						final curAnim = animation[0];
						final duration = curAnim.duration == null ? 0.2 : curAnim.duration;
						final isUser = curAnim.isUser;
						var whoDo:Pokemon = user;
						if (!isUser)
						{
							whoDo = target;
						}
						switch (curAnim.funcName)
						{
							case "moveTo":
								var xPos = curAnim.pos[0];
								if (whoDo.direction == FRONT)
								{
									xPos = -xPos;
								}

								whoDo.moveTo(FlxPoint.weak(xPos, curAnim.pos[1]), duration, onEndStep);
							case "flicker":
								whoDo.flicking(duration, onEndStep);
							default:
								onEndStep();
						}
					}
					else
					{
						finish();
					}
				}
			}
			else
			{
				finish();
			}
		}
		super.update(elapsed);
	}
}
