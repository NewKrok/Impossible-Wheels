package iw.menu;

import com.greensock.TweenMax;
import com.greensock.easing.Quad;
import iw.game.GameState;
import iw.game.World;
import iw.menu.MenuModel.MenuSubState;
import iw.menu.substate.InfoPage;
import iw.menu.substate.LevelSelectPage;
import iw.menu.substate.SettingsPage;
import iw.menu.substate.WelcomePage;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import hpp.heaps.HppG;
import hpp.util.Log;
import hxd.Res;
import iw.AppModel;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class MenuState extends Base2dState
{
	var appModel:AppModel;
	var menuModel:MenuModel;

	var world:World;

	var welcomePage:WelcomePage;
	var infoPage:InfoPage;
	var settingsPage:SettingsPage;
	var levelSelectPage:LevelSelectPage;

	public function new(stage:Base2dStage, appModel:AppModel)
	{
		this.appModel = appModel;
		menuModel = new MenuModel();

		super(stage);
	}

	override function build()
	{
		super.build();

		welcomePage = new WelcomePage(
			menuModel.setSubState.bind(Settings),
			menuModel.setSubState.bind(Info),
			menuModel.setSubState.bind(LevelSelect)
		);

		infoPage = new InfoPage(
			menuModel.setSubState.bind(Welcome)
		);

		settingsPage = new SettingsPage(
			appModel,
			menuModel.setSubState.bind(Welcome)
		);

		levelSelectPage = new LevelSelectPage(
			startLevelRequest,
			appModel,
			menuModel.setSubState.bind(Welcome)
		);

		menuModel.observables.subState.bind(function(s)
		{
			Log.info('Change menu state to: $s');
			switch(s)
			{
				case MenuSubState.Intro:
					world.jumpCameraTo(600, -600);
					world.moveCameraTo(600, 400, 1).onComplete = menuModel.setSubState.bind(MenuSubState.Welcome);

				case MenuSubState.Welcome:
					openSubState(welcomePage);
					world.moveCameraTo(600, 400, 1);
					world.zoomCamera(1, 1, Quad.easeOut);

				case MenuSubState.Info:
					openSubState(infoPage);
					world.moveCameraTo(1000, 200, 1);

				case MenuSubState.Settings:
					openSubState(settingsPage);
					world.moveCameraTo(0, 200, 1);

				case MenuSubState.LevelSelect:
					openSubState(levelSelectPage);
					world.moveCameraTo(0, 0, 1);
					world.zoomCamera(.5, 1, Quad.easeOut);

				case _:
			}
		});

		world = new World(
			stage,
			appModel.getLevelData(0).levelData,
			true,
			appModel.observables.isEffectEnabled,
			menuModel.observables.isLoaded,
			menuModel.observables.isNotInFocus
		);

		menuModel.setSubState(MenuSubState.Intro);

		world.build().onComplete = function() {
			menuModel.isLoaded = true;
			menuModel.isInFocus = true;
			chooseDemoReplay();
		}
	}

	function chooseDemoReplay()
	{
		var rnd = Math.floor(Math.random() * 7);
		Log.info('Play replay in menu: $rnd');

		world.playReplay(switch(rnd)
		{
			case 1: Res.data.replay.demo.demo_1.entry.getText();
			case 2: Res.data.replay.demo.demo_2.entry.getText();
			case 3: Res.data.replay.demo.demo_3.entry.getText();
			case 4: Res.data.replay.demo.demo_4.entry.getText();
			case 5: Res.data.replay.demo.demo_5.entry.getText();
			case 6: Res.data.replay.demo.demo_6.entry.getText();
			case _: Res.data.replay.demo.demo_0.entry.getText();
		}).onComplete = function ()
		{
			world.reset();
			chooseDemoReplay();
		}
	}

	function startLevelRequest(levelId:UInt)
	{
		Log.info('Start level request: $levelId');
		HppG.changeState(GameState, [appModel, levelId]);
	}

	override public function update(delta:Float)
	{
		world.update(delta);
	}

	function resumeRequest()
	{
		TweenMax.resumeAll(true, true, true);
		menuModel.isInFocus = true;
	}

	function pauseRequest()
	{
		TweenMax.pauseAll(true, true, true);
		menuModel.isInFocus = false;
	}

	override public function onFocus()
	{
		Log.info("On focus");
		resumeRequest();
	}

	override public function onFocusLost()
	{
		Log.info("On focus lost");
		pauseRequest();
	}

	override public function dispose():Void
	{
		world.destroy();

		welcomePage.dispose();
		infoPage.dispose();
		settingsPage.dispose();
		levelSelectPage.dispose();

		super.dispose();
	}
}
