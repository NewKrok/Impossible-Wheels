package iw.game;

import coconut.data.Model;

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
	@:observable var isLost:Bool = false;
	@:observable var isControlEnabled:Bool = false;
	@:observable var isCameraEnabled:Bool = false;

	@:transition function collectCoin() return { collectedCoins: collectedCoins + 1 };

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
		isControlEnabled: false,
		isCameraEnabled: false
	};

	@:transition function reset() return {
		isLost: false,
		isControlEnabled: true,
		isCameraEnabled: true,
		collectedCoins: 0,
		lifeCount: 3
	};
}