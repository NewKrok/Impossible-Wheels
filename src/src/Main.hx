package;

import coconut.data.List;
import iw.AppModel;
import iw.Fonts;
import iw.data.CarDatas;
import iw.game.GameState;
import haxe.Json;
import iw.menu.MenuState;
import iw.util.LevelUtil;
import iw.util.SaveUtil;
import hpp.heaps.Base2dApp;
import hpp.heaps.Base2dStage.StageScaleMode;
import hpp.util.DeviceData;
import hpp.util.JsFullScreenUtil;
import hpp.util.Language;
import hpp.util.Log;
import hxd.Key;
import hxd.Res;
import hxd.Save;

class Main extends Base2dApp
{
	override function init()
	{
		super.init();

		stage.stageScaleMode = StageScaleMode.SHOW_ALL;

		Log.isEnabled = true;
		SaveUtil.load();
		Fonts.init();

		var appModel:AppModel = new AppModel();
		appModel.setPlatform(DeviceData.isMobile());
		appModel.changeLanguage(SaveUtil.data.app.lang);
		appModel.setIsSoundEnabled(SaveUtil.data.app.isSoundEnabled);
		appModel.setIsMusicEnabled(SaveUtil.data.app.isMusicEnabled);
		appModel.setIsEffectEnabled(SaveUtil.data.app.isEffectEnabled);
		appModel.setLevelStates(SaveUtil.data.game.levelStates);
		appModel.setLevelDatas(List.fromArray([
			{ id: 0, levelData: LevelUtil.LevelDataFromJson(Res.data.level.demo.entry.getText()) },
			{ id: 1, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_0.entry.getText()) },
			{ id: 2, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_0.entry.getText()) },
			{ id: 3, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_0.entry.getText()) },
			{ id: 4, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_0.entry.getText()) },
			{ id: 5, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_0.entry.getText()) },
			{ id: 6, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_0.entry.getText()) },
			{ id: 7, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_0.entry.getText()) },
			{ id: 8, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_0.entry.getText()) },
			{ id: 9, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_0.entry.getText()) },
			{ id: 10, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_0.entry.getText()) },
			{ id: 11, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_0.entry.getText()) },
			{ id: 12, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_0.entry.getText()) }
		]));

		changeState(GameState, [appModel, 1]);
		//changeState(MenuState, [appModel]);
	}

	static function main()
	{
		Res.initEmbed();
		Key.initialize();
		JsFullScreenUtil.init("webgl");

		new Main();
	}
}