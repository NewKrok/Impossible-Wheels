package;

import coconut.data.List;
import hpp.heaps.Base2dApp;
import hpp.heaps.Base2dStage.StageScaleMode;
import hpp.util.DeviceData;
import hpp.util.JsFullScreenUtil;
import hpp.util.Log;
import hxd.Key;
import hxd.Res;
import iw.AppModel;
import iw.Fonts;
import iw.SoundManager;
import iw.game.GameState;
import iw.menu.MenuState;
import iw.util.LevelUtil;
import iw.util.SaveUtil;

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
			{ id: 2, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_1.entry.getText()) },
			{ id: 3, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_2.entry.getText()) },
			{ id: 4, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_3.entry.getText()) },
			{ id: 5, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_1.entry.getText()) },
			{ id: 6, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_1.entry.getText()) },
			{ id: 7, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_1.entry.getText()) },
			{ id: 8, levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_1.entry.getText()) }
		]));
		if (SaveUtil.data.game.wasGameCompleted) appModel.onGameCompleted();

		SoundManager.init(appModel.observables.isSoundEnabled, appModel.observables.isMusicEnabled);

		changeState(GameState, [appModel, 4]); // just for testing
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

// TODO
// Create levels
// Create enemies/replays
// Add mobile touch control
// Check ios/osx performance
// Add game preloader
// Minimize the result