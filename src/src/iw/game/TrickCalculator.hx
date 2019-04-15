package iw.game;

import iw.game.car.PlayerCar;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class TrickCalculator
{
	public static var WHEELIE_MIN_TIME:UInt = 1000;

	var target:PlayerCar = _;

	public var onTrick:TrickType->Void = function(_) {};

	var isOnWheelie:Bool;
	var isBackWheelie:Bool;
	var isOnAir:Bool;
	var onWheelieStartGameTime:Float = 0;
	var onAirStartGameTime:Float = 0;
	var jumpAngle:Float = 0;
	var lastAngleOnGround:Float = 0;

	public function update(gameTime:Float)
	{
		checkFlipState(gameTime);
		checkWheelieState(gameTime);
	}

	function checkWheelieState(gameTime:Float):Void
	{
		var isWheelieInProgress:Bool = (target.rightWheelOnAir && !target.leftWheelOnAir) || (!target.rightWheelOnAir && target.leftWheelOnAir);

		if(!isWheelieInProgress && isOnWheelie && gameTime - onWheelieStartGameTime > WHEELIE_MIN_TIME)
		{
			onTrick(TrickType.Wheelie(
				isBackWheelie ? TrickDirection.Back : TrickDirection.Front,
				gameTime - onWheelieStartGameTime
			));
		}

		if(isWheelieInProgress && !isOnWheelie)
		{
			onWheelieStartGameTime = gameTime;
			isBackWheelie = !target.leftWheelOnAir;
		}

		isOnWheelie = isWheelieInProgress;
	}

	function checkFlipState(gameTime:Float):Void
	{
		if (target.isCarBodyTouchGround)
		{
			isOnAir = false;
			jumpAngle = 0;
			lastAngleOnGround = 0;

			return;
		}

		var newIsOnAirValue:Bool = target.leftWheelOnAir && target.rightWheelOnAir;

		if (target.leftWheelOnAir && target.rightWheelOnAir)
		{
			var currentAngle:Float = Math.atan2(
				target.wheelLeftGraphics.y - target.wheelRightGraphics.y,
				target.wheelLeftGraphics.x - target.wheelRightGraphics.x
			);
			currentAngle = target.wheelLeftGraphics.x - target.wheelRightGraphics.x < 0 ? (Math.PI * 2 + currentAngle) : currentAngle;

			while(currentAngle > Math.PI * 2)
			{
				currentAngle -= Math.PI * 2;
			}

			if(!isOnAir)
			{
				onAirStartGameTime = gameTime;
				isOnAir = true;
				jumpAngle = 0;
				lastAngleOnGround = currentAngle;
			}

			var angleDiff:Float = currentAngle - lastAngleOnGround;

			if(angleDiff < -Math.PI)
			{
				angleDiff += Math.PI * 2;
				angleDiff *= -1;
			}
			else if(angleDiff > Math.PI)
			{
				angleDiff -= Math.PI * 2;
				angleDiff *= -1;
			}

			lastAngleOnGround = currentAngle;
			jumpAngle += angleDiff;
		}
		else if (isOnAir)
		{
			var angleInDeg:Float = jumpAngle * (180 / Math.PI);

			isOnAir = false;
			jumpAngle = 0;
			lastAngleOnGround = 0;

			if(angleInDeg > 200 || angleInDeg < -200)
			{
				onTrick(TrickType.Flip(
					angleInDeg < 0 ? TrickDirection.Back : TrickDirection.Front,
					Math.floor(Math.abs(angleInDeg / 200))
				));
			}
		}
	}
}

enum TrickType
{
	Wheelie(direction:TrickDirection, length:Float);
	Flip(direction:TrickDirection, multiplier:UInt);
}

enum TrickDirection
{
	Front;
	Back;
}