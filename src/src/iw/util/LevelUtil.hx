package iw.util;

import haxe.Json;
import haxe.Log;
import iw.data.LevelData;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LevelUtil
{
	public static function LevelDataFromJson(jsonData:String):LevelData
	{
		var level:LevelData;

		try
		{
			level = Json.parse(jsonData);

			level.starValues = level.starValues == null ? [0, 0, 0] : level.starValues;

			if (level.staticElementData == null) level.staticElementData = [];
			level.staticElementData.push({
				position: { x: level.finishPoint.x, y: level.finishPoint.y },
				pivotX: 5,
				pivotY: 63,
				scaleX: 1,
				scaleY: 1,
				rotation: 0,
				elementId: "finishFlag",
			});
		}
		catch( e:String )
		{
			Log.trace( "[LevelUtil] parsing error" );
			level = null;
		}

		return level;
	}
}