package;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;

using StringTools;

class Text extends FlxBitmapText
{
	private static var letters:String = "ABCDEFGHIJKLMNOP" + "QRSTUVWXYZ():;[]" + "abcdefghijklmnop" + "qrstuvwxyzàèéùÀÁ" + "ÄÖÜäöüÈÉÌÍÑÒÓÙÚá"
		+ "ìíñòóú°&ÇÆÊ^%{}:" + "'|#-¿¡?!.´`“”·+<" + "$*./,>0123456789" + "Å~æßê@√∞Îÿ_=\" ";

	public function new(x:Float = 0, y:Float = 0, text:String = "")
	{
		var font:FlxBitmapFont = FlxBitmapFont.fromMonospace(Paths.images('pokeFont'), letters, FlxPoint.weak(8, 8));

		super(font);
		this.text = text;
		autoSize = false;
		fieldWidth = 18 * 8;
		lineSpacing = 8;
		super.setPosition(x, y);
	}

	override function set_text(value:String):String
	{
		if (value != text)
		{
			value = traslate(value);
		}
		super.set_text(value);
		return value;
	}

	public static function traslate(string:String = ""):String
	{
		string = string.replace("fem", ">");
		string = string.replace("male", "<");
		string = string.replace("'d", "Ç");
		string = string.replace("'l", "Æ");
		string = string.replace("'m", "Ê");
		string = string.replace("'r", "^");
		string = string.replace("'s", "%");
		string = string.replace("'t", "{");
		string = string.replace("'v", "}");
		string = string.replace("poke", "|");
		string = string.replace("mon", "#");

		string = string.replace("*A", "Å");
		string = string.replace("*B", "~");
		string = string.replace("*C", "æ");
		string = string.replace("*D", "ß");
		string = string.replace("*E", "ê");
		string = string.replace("*F", "@");
		string = string.replace("*G", "√");
		string = string.replace("*H", "∞");
		string = string.replace("*I", "Î");
		string = string.replace("*V", "ÿ");
		string = string.replace("*S", "_");
		string = string.replace("*L", "=");
		string = string.replace("*M", "\"");

		return string;
	}
}
