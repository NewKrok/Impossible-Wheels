package iw.game;

import coconut.data.Model;
import iw.util.ScoreCalculator;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameModel implements Model
{
	@:external var levelId:UInt;

	@:editable var gameTime:Float = 0;

	@:observable var collectedCoins:UInt = 0;
	@:observable var lifeCount:UInt = 3;
	@:observable var isLevelCompleted:Bool = false;
	@:observable var isLost:Bool = false;
	@:observable var isControlEnabled:Bool = false;
	@:observable var isCameraEnabled:Bool = true;
	@:observable var isGameStarted:Bool = false;
	@:observable var isGamePaused:Bool = false;
	@:observable var totalScore:UInt = 0;

	@:transition function collectCoin() return { collectedCoins: collectedCoins + 1 };

	@:transition function onLevelComplete() return {
		isLevelCompleted: true,
		isControlEnabled: false,
		isCameraEnabled: false
	};

	@:transition function looseLife()
	{
		if (lifeCount == 1)
		{
			loose();
			return { lifeCount: 0 };
		}
		else return { lifeCount: lifeCount - 1 };
	};

	@:transition function loose() return {
		isLost: true,
		isControlEnabled: false
	};

	@:transition function reset() return {
		isLevelCompleted: false,
		isLost: false,
		isControlEnabled: false,
		isCameraEnabled: true,
		isGameStarted: false,
		isGamePaused: false,
		collectedCoins: 0,
		lifeCount: 3
	};

	@:transition function startLevel() return {
		isControlEnabled: true,
		isGameStarted: true
	};

	@:transition function pauseGame() return { isGamePaused: true };
	@:transition function resumeGame() return { isGamePaused: false };

	@:transition function calculateTotalScore(bonusScore:UInt = 0)
	{
		var result = 0;
		result += ScoreCalculator.lifeCountToScore(lifeCount);
		result += ScoreCalculator.elapsedTimeToScore(gameTime);
		result += ScoreCalculator.collectedCoinsToScore(collectedCoins);
		result += bonusScore;

		return { totalScore: result };
	}
}