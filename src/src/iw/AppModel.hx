package iw;

import coconut.data.List;
import coconut.data.Model;
import haxe.Json;
import iw.AppModel.LangId;
import iw.data.LevelData;
import iw.util.SaveUtil;
import hpp.util.Language;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class AppModel implements Model
{
	@:observable var isMobile:Bool = false;
	@:observable var language:LangId = null;
	@:observable var isSoundEnabled:Bool = null;
	@:observable var isMusicEnabled:Bool = null;
	@:observable var isEffectEnabled:Bool = null;
	@:observable var isFpsEnabled:Bool = null;
	@:observable var wasGameCompleted:Bool = false;

	@:skipCheck @:observable var levelDatas:List<Level> = null;
	@:skipCheck @:observable var levelStates:Map<UInt, LevelState> = null;

	@:transition function setPlatform(isMobile:Bool) return { isMobile: isMobile };

	@:transition function changeLanguage(value:LangId)
	{
		switch(value)
		{
			case En: Language.setLang(Json.parse(Res.lang.lang_en.entry.getText()));
			case Hu: Language.setLang(Json.parse(Res.lang.lang_hu.entry.getText()));
		}

		SaveUtil.data.app.lang = value;
		SaveUtil.save();

		return {
			language: value
		}
	};

	@:transition function setIsSoundEnabled(value:Bool)
	{
		// TODO handle it

		SaveUtil.data.app.isSoundEnabled = value;
		SaveUtil.save();

		return {
			isSoundEnabled: value
		}
	};

	@:transition function setIsMusicEnabled(value:Bool)
	{
		// TODO handle it

		SaveUtil.data.app.isMusicEnabled = value;
		SaveUtil.save();

		return {
			isMusicEnabled: value
		}
	};

	@:transition function setIsEffectEnabled(value:Bool)
	{
		SaveUtil.data.app.isEffectEnabled = value;
		SaveUtil.save();

		return {
			isEffectEnabled: value
		}
	};

	@:transition function setIsFpsEnabled(value:Bool)
	{
		SaveUtil.data.app.isFpsEnabled = value;
		SaveUtil.save();

		return {
			isFpsEnabled: value
		}
	};

	@:transition function setLevelStates(value:Map<UInt, LevelState>)
	{
		SaveUtil.data.game.levelStates = value;
		SaveUtil.save();

		return {
			levelStates: value
		}
	};

	@:transition function setLevelDatas(value:List<Level>) return { levelDatas: value };

	public function getLevelData(id:UInt) return levelDatas.toArray().filter(function(l) { return l.id == id; })[0];

	@:transition function onGameCompleted()
	{
		SaveUtil.data.game.wasGameCompleted = true;
		SaveUtil.save();

		return { wasGameCompleted: true };
	}
}

@:enum abstract LangId(String) from String to String {
  var En = "en";
  var Hu = "hu";
}

typedef Level = {
	var id(default, never):UInt;
	var levelData(default, never):LevelData;
	var replay(default, never):String;
}