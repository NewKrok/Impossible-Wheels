package iw.util;

import haxe.ds.Map;
import hpp.util.DeviceData;
import hxd.Save;

/**
 * ...
 * @author Krisztian Somoracz
 */
class SaveUtil
{
	private static var savedDataName:String = "fpp_Impossible_Wheels";

	public static var data(default, null):SavedData;

	public static function load()
	{
		var defaultData:SavedData = {
			app: {
				lang: "en",
				isSoundEnabled: true,
				isMusicEnabled: true,
				isEffectEnabled: !DeviceData.isMobile()
			},
			game: {
				// Unlock the first level by default (0 is the demo level)
				levelStates: [
					1 => { isUnlocked: true, isCompleted: false, score: 0 }
				],
				wasGameCompleted: false
			}
		};

		data = Save.load(defaultData, savedDataName);
	}

	public static function save() Save.save(data, savedDataName);
}

typedef SavedData = {
	var app:ApplicationInfo;
	var game:GameInfo;
}

typedef ApplicationInfo = {
	var lang:String;
	var isSoundEnabled:Bool;
	var isMusicEnabled:Bool;
	var isEffectEnabled:Bool;
}

typedef GameInfo = {
	var levelStates:Map<UInt, LevelState>;
	var wasGameCompleted:Bool;
}

typedef LevelState = {
	var isUnlocked:Bool;
	var isCompleted:Bool;
	var score:UInt;
}