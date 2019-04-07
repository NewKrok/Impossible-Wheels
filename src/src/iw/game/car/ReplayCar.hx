package iw.game.car;

import apostx.replaykit.IPlaybackPerformer;
import h2d.Bitmap;
import h2d.Layers;
import haxe.Unserializer;
import iw.data.CarData;

class ReplayCar extends AbstractCar implements IPlaybackPerformer
{
	public function unserializeWithTransition(from:Unserializer, to:Unserializer, percent:Float):Void
	{
		unserializeSprite(from, to, percent, carBodyGraphics);
		unserializeSprite(from, to, percent, wheelRightGraphics);
		unserializeSprite(from, to, percent, wheelLeftGraphics);
	}

	private function unserializeSprite(from:Unserializer, to:Unserializer, percent:Float, sprite:Bitmap):Void
	{
		sprite.x = calculateLinearTransitionValue(from.unserialize(), to.unserialize(), percent);
		sprite.y = calculateLinearTransitionValue(from.unserialize(), to.unserialize(), percent);

		var fromAngle:Float = from.unserialize();
		while (fromAngle > Math.PI * 2) fromAngle -= Math.PI * 2;
		var toAngle:Float = to.unserialize();
		while (toAngle > Math.PI * 2) toAngle -= Math.PI * 2;
		if (fromAngle - Math.PI * 2 > toAngle) toAngle += Math.PI * 2;
		if (toAngle - Math.PI * 2 > fromAngle) fromAngle += Math.PI * 2;
		var newAngle:Float = calculateLinearTransitionValue(fromAngle, toAngle, percent);
		sprite.rotation = newAngle;
	}

	private function calculateLinearTransitionValue(from:Float, to:Float, percent:Float):Float
	{
		return from + (to - from) * percent;
	}
}