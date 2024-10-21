package;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxEase;

class PokeSprite extends FlxSprite
{
	var movePos:FlxPoint = null;
	var time:Float = 0;
	var onCompleteFunc:() -> Void;
	var anim:Bool = false;
	var elapsedAnim:Float = 0;
	var framesPassed:Float = 0;
	var lastPos:FlxPoint;
	var animationTime:Map<String, Float> = ["spawning" => 0.3, "faiting" => 0.2, "comeBack" => 0.3];

	public function new(x:Float, y:Float)
	{
		super(x, y);
	}

	override function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):FlxSprite
	{
		final sprite = super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
		sprite.clipRect = new FlxRect(0, 0, width, height);
		return sprite;
	}

	var spawn = false;

	public function spawning(onComplete:() -> Void)
	{
		spawn = true;
		prepareAnim(animationTime.get("spawning"), onComplete);
	}

	var dying = false;

	public function faiting(onComplete:() -> Void)
	{
		dying = true;
		moveTo(FlxPoint.weak(0, height / 8), animationTime.get("faiting"), onComplete);
	}

	var flicker:Bool = false;

	public function flicking(time:Float, onComplete:() -> Void)
	{
		flicker = true;
		prepareAnim(time, onComplete);
	}

	var moving = false;

	public function moveTo(point:FlxPoint, time:Float, onComplete:() -> Void)
	{
		lastPos = new FlxPoint(x, y);
		movePos = point;
		moving = true;
		prepareAnim(time, onComplete);
	}

	function prepareAnim(time:Float, onComplete:() -> Void)
	{
		this.time = time;
		onCompleteFunc = onComplete;
		elapsedAnim = 0;
		framesPassed = 0;
		anim = true;
	}

	override function update(elapsed:Float)
	{
		if (anim)
		{
			final perc = Math.min(elapsedAnim / time, 1);
			elapsedAnim += elapsed;
			framesPassed++;
			if (flicker)
			{
				if (Math.round((framesPassed / FlxG.updateFramerate) * 60) % 8 == 0)
				{
					visible = !visible;
				}
			}
			if (spawn)
			{
				final ease = FlxEase.expoOut(perc);
				clipRect.set(width / 2 - (width * ease) / 2, height - height * ease, width * ease, height * ease);

				clipRect = clipRect;
			}

			if (moving)
			{
				if (dying)
				{
					clipRect.height = height - movePos.y * perc * 8;
					clipRect = clipRect;
				}
				x = lastPos.x + movePos.x * perc * 8;
				y = lastPos.y + movePos.y * perc * 8;
			}

			if (perc >= 1)
			{
				if (onCompleteFunc != null)
					onCompleteFunc();

				anim = false;
				moving = false;
				dying = false;
				spawn = false;
				flicker = false;
				visible = true;
			}
		}
		super.update(elapsed);
	}
}
