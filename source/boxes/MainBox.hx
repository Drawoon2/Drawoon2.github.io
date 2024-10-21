package boxes;

import Selector;
import Text;
import TextBox;

using StringTools;

class MainBox extends TextBox
{
	public var mainText:Text;

	public var interval:Float = 0.05;

	var textToWrite:String = "";
	var realTextToWrite:String = "";

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y, 20, 6);

		mainText = new Text(8, 16, "");
		add(mainText);

		selector = new Selector(144, 32, "down");
		add(selector);
		selector.alpha = 0.00001;
	}

	var isFinish:Bool = true;

	public var onCompleteFunc:() -> Void = null;
	public var nextTexts:Array<String> = [];
	public var textsFunc:Map<String, () -> Bool> = [];

	var curStep:Int = 0;
	var canContinue:Bool = false;

	public function addText(text:String = "", ?func:() -> Bool = null)
	{
		nextTexts.push(text);
		if (func != null)
			textsFunc.set(text, func);
	}

	public function write(text:String = "", ?onComplete:() -> Void = null):Void
	{
		mainText.text = "";
		curStep = 0;
		isFinish = false;
		canContinue = true;
		realTextToWrite = text;
		text = Text.traslate(text).trim();

		var lines:Array<String> = text.split("\n");
		var i:Int = 0;
		while (lines[i] != null)
		{
			var line:String = lines[i];

			if (line.length > 18)
			{
				var textSplit:Array<String> = line.split(" ");
				var newLine:String = null;
				for (j in 0...textSplit.length)
				{
					var part:String = textSplit[j];
					if (newLine == null)
					{
						newLine = part;
						continue;
					}
					if ((newLine + " " + part).length > 18)
					{
						var giveToNextLine = textSplit.slice(j).join(" ");

						if (lines[i + 1] == null)
							lines.push(giveToNextLine);
						else
							lines[i + 1] = giveToNextLine + " " + lines[i + 1];
						break;
					}
					else
						newLine += " " + part;
				}

				lines[i] = newLine;
			}
			i++;
		}
		textToWrite = lines.join("\n");
		onCompleteFunc = onComplete;
	}

	public function loadAllTexts(?func:() -> Void = null)
	{
		if (func != null)
			onCompleteFunc = func;
		if (nextTexts.length > 0)
		{
			var nextText = nextTexts.shift();
			if (nextText != null)
				write(nextText, onCompleteFunc);
		}
		else if (onCompleteFunc != null)
			onCompleteFunc();
	}

	public function erase():Void
	{
		nextTexts = [];
		mainText.text = "";
		curStep = 0;
		isFinish = true;
		canContinue = false;
		onCompleteFunc = null;
	}

	var intervalElapsed:Float = 0;
	var wait:Bool = false;
	var moveUpStep:Int = -1;
	var divider:Float = 1;

	override public function update(elapsed:Float)
	{
		intervalElapsed += elapsed;

		if (intervalElapsed >= (interval / divider) && !isFinish)
		{
			if (!wait)
			{
				curStep++;

				mainText.text = textToWrite.substring(0, curStep);
				if (mainText.numLines > 1 && mainText.text.endsWith("\n"))
				{
					wait = true;
					moveUpStep = -1;
				}
				else if (curStep > textToWrite.length)
					isFinish = true;
			}
			else if (moveUpStep > -1 && moveUpStep < 4)
			{
				moveUpStep++;
				switch (moveUpStep)
				{
					case 1:
						mainText.y -= 8;
					case 2:
						mainText.y += 8;
						var textSplit;
						textSplit = textToWrite.split("\n");
						textSplit.shift();
						curStep = textSplit[0].length;
						textToWrite = textSplit.join("\n");
						mainText.text = textToWrite.substring(0, curStep);
					case 3:
						wait = false;
				}
			}

			intervalElapsed = 0;
		}
		else if (intervalElapsed >= interval * 4 && isFinish)
		{
			selector.visible = !selector.visible;
			intervalElapsed = 0;
		}

		if ((isFinish && canContinue) || (wait && moveUpStep < 0))
		{
			selector.alpha = 1;
		}
		else
		{
			selector.alpha = 0.00001;
		}
		super.update(elapsed);
		if (controls != null)
		{
			if (controls.ACCEPT.justPressed)
			{
				if (wait && moveUpStep < 0)
				{
					moveUpStep = 0;
				}
				else if (isFinish && canContinue)
				{
					canContinue = false;
					var keepWrite:Bool = true;
					if (textsFunc.exists(realTextToWrite))
					{
						var func:() -> Bool = textsFunc.get(realTextToWrite);
						if (func != null)
						{
							keepWrite = func();
							textsFunc.remove(realTextToWrite);
						}
					}
					if (nextTexts.length > 0 && keepWrite)
					{
						var nextText:String = nextTexts.shift();
						if (nextText != null)
							write(nextText, onCompleteFunc);
					}

					if (onCompleteFunc != null && nextTexts.length < 1)
					{
						onCompleteFunc();
					}
				}
			}
			if (controls.ACCEPT.pressed)
				divider = 4;
			else
				divider = 1;
		}
	}
}
