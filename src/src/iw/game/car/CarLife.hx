package iw.game.car;

import com.greensock.TweenMax;

/**
 * ...
 * @author Krisztian Somoracz
 */
class CarLife
{
	public var isInvulnerable(default, null):Bool = false;

	var delayCall:TweenMax;

	public function new() {}

	public function damage()
	{
		isInvulnerable = true;

		delayCall = TweenMax.delayedCall(1, function() {
			isInvulnerable = false;
		});
	}

	public function reset()
	{
		if (delayCall != null) delayCall.kill();
		isInvulnerable = false;
	}

	public function destroy()
	{
		reset();
	}
}