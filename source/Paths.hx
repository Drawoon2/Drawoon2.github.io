package;

import haxe.Json;
import openfl.Assets;

class Paths
{
	public static function getPath(path:String, ext:String = "png")
	{
		return 'assets/${path}.${ext}';
	}

	public static function images(name:String):String
	{
		return getPath('images/${name}', "png");
	}

	public static function data(name:String):Dynamic
	{
		final path = getPath('data/${name}', "json");
		if (!Assets.exists(path))
			return null;

		return Json.parse(Assets.getText(path));
	}
}
