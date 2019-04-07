package iw.util;

/**
 * ...
 * @author Krisztian Somoracz
 */
class StarCountUtil
{
	static public function scoreToStarCount(score:UInt, starValues:Array<UInt>):UInt
	{
		var starCount:UInt = 0;

		for (i in 0...starValues.length)
		{
			if (score >= starValues[i]) starCount = i + 1;
			else return starCount;
		}

		return starCount;
	}
}