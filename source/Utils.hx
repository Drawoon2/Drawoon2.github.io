package;

enum Direction
{
	RIGHT;
	LEFT;
	FRONT;
	BACK;
}

class Utils
{
	public static function loadNumber(number:Float = 0, digiter:Int = 2, ?char:String = "0"):String
	{
		return Std.string(number).lpad(char, digiter);
	}

	public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}
}
