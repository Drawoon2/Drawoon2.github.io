package boxes;

class MultOptionBox extends TextBox
{
	var options:Array<String> = ["SI", "NO"];

	var texts:Array<Text> = [];

	var curSelect(default, set):Int = 0;

	public var onSelect:String->Void;

	public function new(x:Float, y:Float, options:Array<String>, ?spaces:Bool = false, ?customWidth:Int)
	{
		var width:Int = 5;
		if (options != null)
		{
			this.options = options;
			if (customWidth != null)
			{
				width = customWidth;
			}
			else
			{
				for (option in this.options)
				{
					if (width < option.length)
					{
						width = option.length;
					}
				}
				width += 3;
			}
		}

		super(x, y, width, spaces ? this.options.length * 2 + 1 : this.options.length + 2);
		var yPos:Float = 8;
		for (option in this.options)
		{
			var newText = new Text(16, yPos, option);
			texts.push(newText);
			add(newText);
			yPos += spaces ? 16 : 8;
		}
		selector = new Selector(8, 8);
		add(selector);
	}

	override function update(elapsed:Float)
	{
		if (controls != null)
		{
			var move:Int = (controls.UP.justPressed ? -1 : 0) + (controls.DOWN.justPressed ? 1 : 0);
			if (Math.abs(move) > 0)
				curSelect += move;

			selector.y = texts[curSelect].y;
			if (controls.ACCEPT.justPressed)
			{
				if (onSelect != null)
					onSelect(options[curSelect]);
			}
		}
		super.update(elapsed);
	}

	function set_curSelect(value:Int)
	{
		if (value > texts.length - 1)
			value = texts.length - 1;
		if (value < 0)
			value = 0;
		return curSelect = value;
	}
}
