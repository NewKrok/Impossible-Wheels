package iw.util;

import iw.game.TrickCalculator.TrickType;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ScoreCalculator
{
	private static var lifeToScoreValue:UInt = 250;
	private static var maxScoreForTime:UInt = 20000;
	private static var coinToScoreValue:UInt = 75;
	private static var collectedCoinsBonusValue:UInt = 1000;
	private static var flipValue:UInt = 200;
	private static var wheelieSecValue:UInt = 100;

	public static function lifeCountToScore(l:UInt):UInt return l * lifeToScoreValue;

	public static function elapsedTimeToScore(t:Float):Int return Math.floor((1 - t / 60000) * maxScoreForTime);

	public static function collectedCoinsToScore(c:UInt):UInt return c * coinToScoreValue;

	public static function getCollectedCoinMaxBonus():UInt return collectedCoinsBonusValue;

	public static function trickToScore(t):UInt return switch (t)
	{
		case TrickType.Flip(d, m): m * flipValue;
		case TrickType.Wheelie(d, l): Math.floor((Math.floor(l / 100) / 10) * wheelieSecValue);
	}
}