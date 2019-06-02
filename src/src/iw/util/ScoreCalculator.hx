package iw.util;

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

	public static function lifeCountToScore(l:UInt):UInt return l * lifeToScoreValue;

	public static function elapsedTimeToScore(t:Float):UInt return Math.floor(Math.max(1 - t / 60000, 0) * maxScoreForTime);

	public static function collectedCoinsToScore(c:UInt):UInt return c * coinToScoreValue;

	public static function getCollectedCoinMaxBonus():UInt return collectedCoinsBonusValue;
}