package iw.game;

import com.greensock.TweenMax;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import iw.AppModel;
import iw.game.GameModel;
import iw.game.ui.GameUi;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameState extends Base2dState
{
	var appModel:AppModel;

	var gameModel:GameModel;

	var world:World;
	var ui:GameUi;

	public function new(stage:Base2dStage, appModel:AppModel, levelId:UInt)
	{
		this.appModel = appModel;
		gameModel = new GameModel({
			levelId: levelId
		});

		gameModel.observables.isLost.bind(function(v) {
			if (v) TweenMax.delayedCall(1, reset);
		});

		super(stage);
	}

	override function build()
	{
		world = new World(
			stage,
			appModel.getLevelData(gameModel.levelId).levelData,
			false,
			appModel.observables.isEffectEnabled,
			gameModel.observables.isCameraEnabled,
			gameModel.observables.isLost,
			gameModel.collectCoin
		);
		world.onLooseLife = gameModel.looseLife;
		world.onLoose = gameModel.loose;
		world.build().onComplete = init;

		ui = new GameUi(
			stage,
			resumeRequest,
			pauseRequest,
			gameModel.observables.gameTime,
			gameModel.observables.collectedCoins,
			gameModel.observables.lifeCount
		);

		world.onTrick = ui.onTrick;
	}

	function init()
	{
		reset();
	}

	function reset()
	{
		gameModel.reset();
		world.reset();

		var startPoint = appModel.getLevelData(gameModel.levelId).levelData.startPoint;
		world.jumpCameraTo(startPoint.x + 300, startPoint.y);
	}

	function start():Void
	{
		resumeRequest();

		world.resume();
	}

	override public function update(delta:Float)
	{
		world.update(delta);

		gameModel.gameTime = world.getGameTime();
	}

	function resumeRequest()
	{
		TweenMax.resumeAll(true, true, true);

		world.resume();
	}

	function pauseRequest()
	{
		TweenMax.pauseAll(true, true, true);

		world.pause();
	}

	override public function onFocus()
	{
		resumeRequest();
	}

	override public function onFocusLost()
	{
		pauseRequest();
	}

	override public function dispose()
	{
		world.destroy();

		super.dispose();
	}
}