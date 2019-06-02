package iw.game;

import com.greensock.TweenMax;
import h2d.filter.Blur;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import hpp.heaps.HppG;
import hxd.Event;
import hxd.Key;
import hxd.Window;
import iw.AppModel;
import iw.game.GameModel;
import iw.game.substate.LevelCompletePage;
import iw.game.substate.PausePage;
import iw.game.ui.GameUi;
import iw.menu.MenuState;

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

	var pausePage:PausePage;
	var levelCompletePage:LevelCompletePage;

	public function new(stage:Base2dStage, appModel:AppModel, levelId:UInt)
	{
		this.appModel = appModel;
		gameModel = new GameModel(
		{
			levelId: levelId
		});

		gameModel.observables.isLost.bind(function(v)
		{
			if (v) TweenMax.delayedCall(1, reset);
		});

		gameModel.observables.isLevelCompleted.bind(function(v)
		{
			if (v) openSubState(levelCompletePage);
			ui.visible = !v;
		});

		gameModel.observables.isGamePaused.bind(function(v)
		{
			if (v)
			{
				if (gameModel.isGameStarted && !gameModel.isLevelCompleted)
				{
					openSubState(pausePage);
					world.filter = new Blur(15);
				}
			}
			else
			{
				world.filter = null;
				if (!gameModel.isLevelCompleted) closeSubState();
			}
		});

		Window.getInstance().addEventTarget(onKeyEvent);

		super(stage);
	}

	function onKeyEvent(e:Event)
	{
		if (e.kind == EKeyDown)
			switch (e.keyCode)
			{
				case Key.P if (gameModel.isGameStarted && !gameModel.isGamePaused): pauseRequest();
				case Key.P if (gameModel.isGameStarted && gameModel.isGamePaused): resumeRequest();

				case Key.R if (gameModel.isGameStarted && gameModel.isGamePaused): reset();
			}
	}

	override function build()
	{
		var levelData = appModel.getLevelData(gameModel.levelId).levelData;

		pausePage = new PausePage(
			resumeRequest,
			reset,
			HppG.changeState.bind(MenuState, [appModel])
		);

		levelCompletePage = new LevelCompletePage(
			gameModel.observables.lifeCount,
			gameModel.observables.gameTime,
			gameModel.observables.collectedCoins,
			levelData.collectableItems.length,
			levelData.opponentsScore,
			HppG.changeState.bind(MenuState, [appModel]),
			reset,
			HppG.changeState.bind(GameState, [appModel, gameModel.levelId + 1])
		);

		world = new World(
			stage,
			levelData,
			false,
			appModel.observables.isEffectEnabled,
			gameModel.observables.isGameStarted,
			gameModel.observables.isGamePaused,
			gameModel.observables.isLevelCompleted,
			gameModel.observables.isCameraEnabled,
			gameModel.observables.isControlEnabled,
			gameModel.observables.isLost,
			gameModel.collectCoin
		);
		world.onLevelComplete = gameModel.onLevelComplete;
		world.onLooseLife = gameModel.looseLife;
		world.onLoose = gameModel.loose;
		world.build().onComplete = init;

		ui = new GameUi(
			stage,
			pauseRequest,
			levelData.levelId,
			gameModel.observables.gameTime,
			gameModel.observables.collectedCoins,
			levelData.collectableItems.length,
			gameModel.observables.lifeCount,
			gameModel.observables.isGamePaused,
			gameModel.observables.isGameStarted
		);

		world.onTrick = ui.onTrick;
	}

	function init()
	{
		reset();
	}

	function reset()
	{
		closeSubState();

		gameModel.reset();
		world.reset();
		ui.showCounter();

		TweenMax.delayedCall(2, gameModel.startLevel);

		var startPoint = appModel.getLevelData(gameModel.levelId).levelData.startPoint;
		world.jumpCameraTo(startPoint.x + 300, startPoint.y);
	}

	function start():Void
	{
		resumeRequest();
	}

	override public function update(delta:Float)
	{
		world.update(delta);

		gameModel.gameTime = world.getGameTime();
	}

	function resumeRequest()
	{
		if (gameModel.isGameStarted && !gameModel.isLevelCompleted)
		{
			ui.showCounter();
			closeSubState();

			TweenMax.delayedCall(2, function()
			{
				TweenMax.resumeAll(true, true, true);
				gameModel.resumeGame();
			});
		}
		else
		{
			TweenMax.resumeAll(true, true, true);
			gameModel.resumeGame();
		}
	}

	function pauseRequest()
	{
		TweenMax.pauseAll(true, true, true);

		// To handle when focus lost during start counter
		if (gameModel.isGamePaused) gameModel.resumeGame();

		gameModel.pauseGame();
	}

	override public function onFocusLost()
	{
		pauseRequest();
	}

	override public function onFocus():Void
	{
		// To handle when focus lost during first start counter or during level completed page
		if (!gameModel.isGameStarted || gameModel.isLevelCompleted) resumeRequest();
	}

	override public function dispose()
	{
		world.destroy();

		super.dispose();
	}
}