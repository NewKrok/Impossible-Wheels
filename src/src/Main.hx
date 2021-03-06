package;

import coconut.data.List;
import h3d.Engine;
import haxe.Timer;
import hpp.heaps.Base2dApp;
import hpp.heaps.Base2dStage.StageScaleMode;
import hpp.util.DeviceData;
import hpp.util.JsFullScreenUtil;
import hpp.util.Log;
import hxd.App;
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
		appModel.setIsFpsEnabled(SaveUtil.data.app.isFpsEnabled);
		appModel.setLevelStates(SaveUtil.data.game.levelStates);
		appModel.setLevelDatas(List.fromArray([
			{
				id: 0,
				levelData: LevelUtil.LevelDataFromJson(Res.data.level.demo.entry.getText()),
				replay: ""
			},
			{
				id: 1,
				levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_0.entry.getText()),
				replay: Res.data.replay.world_0.replay_0_0.entry.getText()
			},
			{
				id: 2,
				levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_1.entry.getText()),
				replay: Res.data.replay.world_0.replay_0_1.entry.getText()
			},
			{
				id: 3,
				levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_2.entry.getText()),
				replay: Res.data.replay.world_0.replay_0_2.entry.getText()
			},
			{
				id: 4,
				levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_3.entry.getText()),
				replay: Res.data.replay.world_0.replay_0_3.entry.getText()
			},
			{
				id: 5,
				levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_4.entry.getText()),
				replay: Res.data.replay.world_0.replay_0_4.entry.getText()
			},
			{
				id: 6,
				levelData: LevelUtil.LevelDataFromJson(Res.data.level.world_0.level_0_5.entry.getText()),
				replay: Res.data.replay.world_0.replay_0_5.entry.getText()
			}
		]));

		if (SaveUtil.data.game.wasGameCompleted) appModel.onGameCompleted();

		SoundManager.init(appModel.observables.isSoundEnabled, appModel.observables.isMusicEnabled);

		//changeState(GameState, [appModel, 1]); // just for testing
		changeState(MenuState, [appModel]);
	}

	static function main()
	{
		Res.initEmbed({compressSounds:true});
		Key.initialize();
		JsFullScreenUtil.init("webgl");

		// It looks Heaps need a little time to init assets, but I don't see related event to handle it properly
		// Without this delay sometimes it use wrong font
		Timer.delay(function() { new Main(); }, 500);
	}
}

// TODO - maybe once...
// Minimize the result - It looks can't use closure
// Fix ios vector graphic lagging - looks like heaps issue