package iw.game;

import apostx.replaykit.Playback;
import apostx.replaykit.Recorder;
import com.greensock.TweenMax;
import com.greensock.easing.Linear;
import h2d.Graphics;
import h2d.Layers;
import haxe.Timer;
import iw.AppModel;
import iw.data.CarDatas;
import iw.data.LevelData;
import iw.game.GameModel;
import iw.game.car.PlayerCar;
import iw.game.constant.CPhysicsValue;
import iw.menu.substate.InfoPage;
import iw.menu.substate.LevelSelectPage;
import iw.menu.substate.SettingsPage;
import iw.menu.substate.WelcomePage;
import iw.game.ui.GameUi;
import iw.util.LevelUtil;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Key;
import hxd.Res;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.space.Space;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameState extends Base2dState
{
	var appModel:AppModel;

	var recorder:Recorder;
	var replayDatas:Array<String>;
	var playbacks:Array<Playback>;

	var gameModel:GameModel;

	var world:World;
	var ui:GameUi;

	var levelData:LevelData;

	var playerCar:PlayerCar;

	var now:Float;

	var isCameraAllowed:Bool = false;

	var isLost:Bool = false;
	var isWon:Bool = false;
	var isLevelFinished:Bool = false;
	var canControll:Bool = false;
	var isGameStarted:Bool = false;
	var isRaceStarted:Bool = false;
	var isGamePaused:Bool = false;
	var isDemoFinished:Bool = false;
	var isMenuMode:Bool = true;
	var isRecordingMode:Bool = true;

	var gameTime:Float = 0;
	var gameStartTime:Float = 0;
	var pauseStartTime:Float = 0;
	var totalPausedTime:Float = 0;

	public function new(stage:Base2dStage, appModel:AppModel, levelId:UInt)
	{
		this.appModel = appModel;
		gameModel = new GameModel({
			levelId: levelId
		});

		super(stage);
	}

	override function build()
	{
		world = new World(
			stage,
			appModel.getLevelData(gameModel.levelId).levelData,
			true,
			appModel.observables.isEffectEnabled
		);

		//ui = new GameUi(resumeRequest, pauseRequest, stage);
	}

	function reset()
	{
		isRaceStarted = false;
		isGameStarted = false;
		isGamePaused = false;
		isCameraAllowed = true;
		isDemoFinished = false;

		gameTime = 0;
		totalPausedTime = 0;
		pauseStartTime = 0;

		if (!isMenuMode)
		{
			/*gameContainer.x = -levelData.startPoint.x + cameraOffset.x;
			gameContainer.y = -levelData.startPoint.y + cameraOffset.y + 500;*/
		}

		resetReplayKit();

		start();
	}

	function start():Void
	{
		isGameStarted = true;

		now = gameStartTime = Date.now().getTime();

		resumeRequest();

		world.resume();
	}

	function resetReplayKit()
	{
		if (!isMenuMode && isRecordingMode)
		{
			if (recorder != null) recorder.dispose();
			recorder = new Recorder(playerCar);
			recorder.enableAutoRecording(100);
		}

		if (playbacks != null)
		{
			for (playback in playbacks)
			{
				playback.dispose();
				playbacks.remove(playback);
			}
		}
		playbacks = [];

		if (replayDatas != null)
		{
			for (i in 0...replayDatas.length)
			{
				/*replayCars[i].reset();
				var playback = new Playback(replayCars[i], replayDatas[i]);
				playback.showSnapshot(0);
				playbacks.push(playback);*/
			}
		}
	}

	override public function update(delta:Float)
	{
		now = Date.now().getTime();

		if (isCameraAllowed)
		{

			/*var cameraPointX = -playerCar.x + cameraOffset.x;
			var cameraPointY = -playerCar.y + cameraOffset.y;
			gameContainer.x -= (gameContainer.x - cameraPointX) / cameraEasing.x;
			gameContainer.y -= (gameContainer.y - cameraPointY) / cameraEasing.y;*/
		}

		if (isGamePaused/* || !isBuilt*/) return;

		world.update(delta);
		calculateGameTime();

		if (!isMenuMode)
		{
			if (Key.isDown(Key.UP)) playerCar.accelerateToRight();
			else if (Key.isDown(Key.DOWN)) playerCar.accelerateToLeft();
			else playerCar.idle();

			if (Key.isDown(Key.LEFT)) playerCar.rotateLeft();
			else if (Key.isDown(Key.RIGHT)) playerCar.rotateRight();
		}
		/*else if (replayCars[0].x > 1800 || replayCars[0].y > 1200)
		{
			if (isDemoFinished) return;
			else
			{
				isDemoFinished = true;

				Timer.delay(function() {
					chooseDemoReplay();
					resetReplayKit();
					gameStartTime = now;
					totalPausedTime = 0;
					pauseStartTime = 0;
					isDemoFinished = false;
				}, 500);

				return;
			}
		}*/

		if (!isMenuMode) playerCar.update(delta);

		if (playbacks != null)
		{
			for (playback in playbacks) playback.showSnapshot(gameTime);
			//for (car in replayCars) car.update(delta);
		}
	}

	function calculateGameTime():Void
	{
		if (isGameStarted) gameTime = now - gameStartTime - totalPausedTime;
		else gameTime = 0;
	}

	override public function onStageResize(width:UInt, height:UInt)
	{
		super.onStageResize(width, height);
	}

	function resumeRequest()
	{
		TweenMax.resumeAll(true, true, true);

		isRaceStarted = true;
		isGamePaused = false;
		world.resume();

		if (pauseStartTime != 0) totalPausedTime += now - pauseStartTime;
		pauseStartTime = 0;

		if (recorder != null) recorder.resume();
	}

	function pauseRequest()
	{
		TweenMax.pauseAll(true, true, true);

		isGamePaused = true;
		world.pause();

		if (pauseStartTime != 0) totalPausedTime += now - pauseStartTime;
		pauseStartTime = now;

		if (recorder != null) recorder.pause();
	}

	override public function onFocus()
	{
		resumeRequest();
	}

	override public function onFocusLost()
	{
		pauseRequest();

		if (!isMenuMode && isRecordingMode)
		{
			recorder.takeSnapshot();
			trace(recorder.toString());
		}
	}

	override public function dispose()
	{

	}
}