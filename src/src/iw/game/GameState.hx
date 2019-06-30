package iw.game;

import com.greensock.TweenMax;
import h2d.filter.Blur;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import hpp.heaps.HppG;
import hpp.util.Log;
import hxd.Event;
import hxd.Key;
import hxd.Res;
import hxd.Window;
import hxd.res.Sound;
import hxd.snd.Channel;
import hxd.snd.Manager;
import iw.AppModel;
import iw.data.LevelData;
import iw.game.GameModel;
import iw.game.substate.LevelCompletePage;
import iw.game.substate.PausePage;
import iw.game.ui.GameUi;
import iw.menu.MenuState;
import iw.util.SaveUtil.LevelState;
import iw.util.ScoreCalculator;
import iw.util.StarCountUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameState extends Base2dState
{
	var appModel:AppModel;
	var gameModel:GameModel;
	var levelData:LevelData;
	var replay:String;

	var world:World;
	var ui:GameUi;

	var pausePage:PausePage;
	var levelCompletePage:LevelCompletePage;

	var backgroundLoopMusic:Sound;
	var backgroundLoopChannel:Channel;

	public function new(stage:Base2dStage, appModel:AppModel, levelId:UInt)
	{
		Log.info('Create game request, level $levelId');

		this.appModel = appModel;
		gameModel = new GameModel(
		{
			levelId: levelId
		});
		levelData = appModel.getLevelData(gameModel.levelId).levelData;
		replay = appModel.getLevelData(gameModel.levelId).replay;

		gameModel.observables.isLost.bind(function(v)
		{
			if (v)
			{
				SoundManager.playLooseSound();
				TweenMax.delayedCall(1, reset);
			}
		});

		gameModel.observables.isLevelCompleted.bind(function(v)
		{
			if (v)
			{
				backgroundLoopChannel.volume = .4;
				SoundManager.playWinSound();

				var levelStates = appModel.levelStates;
				var levelState:LevelState;

				levelState = levelStates.get(levelId);

				gameModel.calculateTotalScore(gameModel.collectedCoins == levelData.collectableItems.length ? ScoreCalculator.getCollectedCoinMaxBonus() : 0);
				var didPlayerWin:Bool = gameModel.totalScore > levelData.opponentsScore;

				levelCompletePage.setStarCount(StarCountUtil.scoreToStarCount(gameModel.totalScore, levelData.starValues));
				levelCompletePage.setIsNewHighScore(levelState.score != 0 && gameModel.totalScore > levelState.score);
				levelCompletePage.needShowGameCompletedWindow = didPlayerWin && levelId == 6 && !appModel.wasGameCompleted;
				levelCompletePage.isLastLevel = levelId == 6;
				levelCompletePage.isNextLevelEnabled = levelId != 6 && (didPlayerWin || levelState.isCompleted);

				openSubState(levelCompletePage);

				if (didPlayerWin)
				{
					if (!levelState.isCompleted)
					{
						levelState.isCompleted = true;
						if (levelId < 6)
						{
							var nextLevelState = { isUnlocked: true, isCompleted: false, score: 0 };
							levelStates.set(levelId + 1, nextLevelState);
						}
					}
					if (levelState.score < gameModel.totalScore) levelState.score = gameModel.totalScore;

					levelStates.set(levelId, levelState);
					appModel.setLevelStates(levelStates);

					if (levelId == 6) appModel.onGameCompleted();
				}
			}
			else
			{
				backgroundLoopChannel.volume = .8;
			}
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
		backgroundLoopMusic = if (Sound.supportedFormat(Mp3)) Res.sound.The_Sewer_Rat_Puzzle_Game else null;
		if (backgroundLoopMusic != null)
		{
			backgroundLoopChannel = backgroundLoopMusic.play(true, .8);

			appModel.observables.isMusicEnabled.bind({ direct:true }, function (v) {
				backgroundLoopChannel.pause = !v;
			});
		}

		pausePage = new PausePage(
			resumeRequest,
			reset,
			HppG.changeState.bind(MenuState, [appModel])
		);

		levelCompletePage = new LevelCompletePage(
			gameModel.observables.lifeCount,
			gameModel.observables.gameTime,
			gameModel.observables.collectedCoins,
			gameModel.observables.trickScore,
			levelData.collectableItems.length,
			levelData.opponentsScore,
			gameModel.observables.totalScore,
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
			gameModel.levelId,
			gameModel.observables.gameTime,
			gameModel.observables.collectedCoins,
			levelData.collectableItems.length,
			gameModel.observables.lifeCount,
			gameModel.observables.isGamePaused,
			gameModel.observables.isGameStarted
		);

		// TODO Add score for tricks
		world.onTrick = function(t)
		{
			gameModel.addTrickScore(ScoreCalculator.trickToScore(t));
			ui.onTrick(t);
		}
	}

	function init()
	{
		reset();
		world.initGhost(replay);
	}

	function reset()
	{
		closeSubState();

		gameModel.reset();
		world.reset();
		ui.reset();
		ui.showCounter();

		TweenMax.delayedCall(2, gameModel.startLevel);

		var startPoint = appModel.getLevelData(gameModel.levelId).levelData.startPoint;
		world.jumpCameraTo(startPoint.x + 300, startPoint.y);

		Manager.get().masterChannelGroup.mute = false;
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

		Manager.get().masterChannelGroup.mute = false;
	}

	function pauseRequest()
	{
		TweenMax.pauseAll(true, true, true);

		// To handle when focus lost during start counter
		if (gameModel.isGamePaused) gameModel.resumeGame();

		gameModel.pauseGame();

		Manager.get().masterChannelGroup.mute = true;
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
		if (backgroundLoopMusic != null)
		{
			backgroundLoopMusic.stop();
			backgroundLoopMusic = null;
		}

		world.destroy();
		world = null;

		ui.dispose();
		ui = null;

		super.dispose();
	}
}