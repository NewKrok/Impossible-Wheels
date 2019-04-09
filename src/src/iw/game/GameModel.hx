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

	@:transition function collectCoin() return { collectedCoins: collectedCoins + 1 };
}