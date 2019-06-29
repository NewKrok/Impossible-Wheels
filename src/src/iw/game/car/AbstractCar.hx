package iw.game.car;

import com.greensock.TweenMax;
import h2d.Bitmap;
import h2d.Object;
import h2d.Particles;
import haxe.Timer;
import iw.data.CarData;
import hpp.util.GeomUtil;
import hxd.Res;
import tink.state.Observable;

class AbstractCar
{
	var carData:CarData;

	var frontSpringHorizontalOffset:Float = 60;
	var frontSpringVerticalOffset:Float = 1;
	var backSpringHorizontalOffset:Float = 55;
	var backSpringVerticalOffset:Float = 14;
	var backTopHolderHorizontalOffset:Float = -9;
	var backTopHolderVerticalOffset:Float = 45;
	var backBottomHolderHorizontalOffset:Float = -11;
	var backBottomHolderVerticalOffset:Float = 62;
	var frontTopHolderHorizontalOffset:Float = 11;
	var frontTopHolderVerticalOffset:Float = 35;
	var frontBottomHolderHorizontalOffset:Float = 9;
	var frontBottomHolderVerticalOffset:Float = 52;
	var smokeHorizontalOffset:Float = -150;
	var smokeVerticalOffset:Float = 10;

	public var carScale:Float;
	public var carBodyGraphics:Bitmap;
	public var wheelRightGraphics:Bitmap;
	public var wheelLeftGraphics:Bitmap;
	public var wheelBackTopHolderGraphics:Bitmap;
	public var wheelBackBottomHolderGraphics:Bitmap;
	public var wheelFrontTopHolderGraphics:Bitmap;
	public var wheelFrontBottomHolderGraphics:Bitmap;
	public var backSpring:Bitmap;
	public var frontSpring:Bitmap;

	public var x(get, never):Float;
	public var y(get, never):Float;
	public var alpha(get, set):Float;

	var carBodyAngleCos:Float = 0;
	var carBodyAngleSin:Float = 0;
	var carBodyAngleRotatedCos:Float = 0;
	var carBodyAngleRotatedSin:Float = 0;

	var particles:Particles;
	var smokeParticleGroup:ParticleGroup;
	var explosionParticleGroup:ParticleGroup;
	var container:Object;

	var isCrushed:Bool = false;

	var isEffectEnabled:Observable<Bool>;

	public function new(parent:Object, carData:CarData, scale:Float = 1, isEffectEnabled:Observable<Bool>)
	{
		container = new Object(parent);
		particles = new Particles(parent);

		carScale = scale;

		this.carData = carData;

		buildGraphics();
		buildSmoke();

		frontSpringHorizontalOffset *= carScale;
		frontSpringVerticalOffset *= carScale;
		backSpringHorizontalOffset *= carScale;
		backSpringVerticalOffset *= carScale;
		backTopHolderHorizontalOffset *= carScale;
		backTopHolderVerticalOffset *= carScale;
		backBottomHolderHorizontalOffset *= carScale;
		backBottomHolderVerticalOffset *= carScale;
		frontTopHolderHorizontalOffset *= carScale;
		frontTopHolderVerticalOffset *= carScale;
		frontBottomHolderHorizontalOffset *= carScale;
		frontBottomHolderVerticalOffset *= carScale;

		this.isEffectEnabled = isEffectEnabled;
		isEffectEnabled.bind(function(v) {
			smokeParticleGroup.enable = v;
			if (v) particles.addGroup(smokeParticleGroup);
			else particles.removeGroup(smokeParticleGroup);
		});

		carBodyGraphics.move(-2000, -2000);
		wheelLeftGraphics.move(-2000, -2000);
		wheelRightGraphics.move(-2000, -2000);
		backSpring.move(-2000, -2000);
		frontSpring.move(-2000, -2000);
		wheelBackBottomHolderGraphics.move(-2000, -2000);
		wheelFrontBottomHolderGraphics.move(-2000, -2000);
		wheelBackTopHolderGraphics.move(-2000, -2000);
		wheelFrontTopHolderGraphics.move(-2000, -2000);
	}

	function buildGraphics():Void
	{
		backSpring = new Bitmap(Res.image.car.spring.toTile(), container);
		backSpring.scale(carScale);
		backSpring.smooth = true;
		backSpring.tile.dx = 0;
		backSpring.tile.dy = cast -backSpring.tile.height / 2;

		frontSpring = new Bitmap(Res.image.car.spring.toTile(), container);
		frontSpring.scale(carScale);
		frontSpring.smooth = true;
		frontSpring.tile.dx = 0;
		frontSpring.tile.dy = cast -frontSpring.tile.height / 2;

		carBodyGraphics = new Bitmap(Res.image.car.body.toTile(), container);
		carBodyGraphics.scale(carScale);
		carBodyGraphics.smooth = true;
		carBodyGraphics.tile.dx = cast -carBodyGraphics.tile.width / 2;
		carBodyGraphics.tile.dy = cast -carBodyGraphics.tile.height / 2;

		wheelBackTopHolderGraphics = new Bitmap(Res.image.car.wheel_holder.toTile(), container);
		wheelBackTopHolderGraphics.scale(carScale);
		wheelBackTopHolderGraphics.smooth = true;
		wheelBackTopHolderGraphics.tile.dx = 0;
		wheelBackTopHolderGraphics.tile.dy = 0;

		wheelBackBottomHolderGraphics = new Bitmap(Res.image.car.wheel_holder.toTile(), container);
		wheelBackBottomHolderGraphics.scale(carScale);
		wheelBackBottomHolderGraphics.smooth = true;
		wheelBackBottomHolderGraphics.tile.dx = 0;
		wheelBackBottomHolderGraphics.tile.dy = 0;

		wheelFrontTopHolderGraphics = new Bitmap(Res.image.car.wheel_holder.toTile(), container);
		wheelFrontTopHolderGraphics.scale(carScale);
		wheelFrontTopHolderGraphics.smooth = true;
		wheelFrontTopHolderGraphics.tile.dx = 0;
		wheelFrontTopHolderGraphics.tile.dy = 0;

		wheelFrontBottomHolderGraphics = new Bitmap(Res.image.car.wheel_holder.toTile(), container);
		wheelFrontBottomHolderGraphics.scale(carScale);
		wheelFrontBottomHolderGraphics.smooth = true;
		wheelFrontBottomHolderGraphics.tile.dx = 0;
		wheelFrontBottomHolderGraphics.tile.dy = 0;

		wheelRightGraphics = new Bitmap(Res.image.car.wheel.toTile(), container);
		wheelRightGraphics.scale(carScale);
		wheelRightGraphics.smooth = true;
		wheelRightGraphics.tile.dx = cast -wheelRightGraphics.tile.width / 2;
		wheelRightGraphics.tile.dy = cast -wheelRightGraphics.tile.height / 2;

		wheelLeftGraphics = new Bitmap(Res.image.car.wheel.toTile(), container);
		wheelLeftGraphics.scale(carScale);
		wheelLeftGraphics.smooth = true;
		wheelLeftGraphics.tile.dx = cast -wheelLeftGraphics.tile.width / 2;
		wheelLeftGraphics.tile.dy = cast -wheelLeftGraphics.tile.height / 2;
	}

	function buildSmoke()
	{
		smokeParticleGroup = new ParticleGroup(particles);
		smokeParticleGroup.size = carScale * .8;
		smokeParticleGroup.sizeRand = .4;
		smokeParticleGroup.gravity = 300;
		smokeParticleGroup.gravityAngle = Math.PI;
		smokeParticleGroup.life = .6;
		smokeParticleGroup.lifeRand = .2;
		smokeParticleGroup.speed = 30 * carScale;
		smokeParticleGroup.nparts = 50;
		smokeParticleGroup.emitMode = PartEmitMode.Point;
		smokeParticleGroup.emitDist = 10 * carScale;
		smokeParticleGroup.speedRand = 2;
		smokeParticleGroup.rotSpeed = 3;
		smokeParticleGroup.fadeIn = 0;
		smokeParticleGroup.fadeOut = 0;
		smokeParticleGroup.texture = Res.image.car.smoke.toTexture();
		smokeParticleGroup.rebuildOnChange = false;
		particles.addGroup(smokeParticleGroup);
	}

	public function crash()
	{
		isCrushed = true;

		if (isEffectEnabled.value)
		{
			smokeParticleGroup.enable = false;

			explosionParticleGroup = new ParticleGroup(particles);
			explosionParticleGroup.size = carScale * .5;
			explosionParticleGroup.sizeRand = 12;
			explosionParticleGroup.life = .4;
			explosionParticleGroup.lifeRand = .4;
			explosionParticleGroup.speed = 300 * carScale;
			explosionParticleGroup.nparts = 30;
			explosionParticleGroup.emitLoop = false;
			explosionParticleGroup.emitMode = PartEmitMode.Point;
			explosionParticleGroup.emitDist = 10 * carScale;
			explosionParticleGroup.speedRand = .5;
			explosionParticleGroup.rotSpeed = 3;
			explosionParticleGroup.fadeIn = 1;
			explosionParticleGroup.fadeOut = 0;
			explosionParticleGroup.texture = Res.image.car.smoke.toTexture();
			explosionParticleGroup.rebuildOnChange = false;
			explosionParticleGroup.animationRepeat = 1;

			particles.addGroup(explosionParticleGroup);
		}
	}

	public function update(elapsed:Float):Void
	{
		carBodyAngleCos = Math.cos(carBodyGraphics.rotation);
		carBodyAngleSin = Math.sin(carBodyGraphics.rotation);
		carBodyAngleRotatedCos = Math.cos(carBodyGraphics.rotation + Math.PI / 2);
		carBodyAngleRotatedSin = Math.sin(carBodyGraphics.rotation + Math.PI / 2);


		updateSpringGraphic();
		updateWheelHolderGraphic();

		if (isCrushed && isEffectEnabled.value)
		{
			explosionParticleGroup.dx = cast carBodyGraphics.x;
			explosionParticleGroup.dy = cast carBodyGraphics.y;
		}

		smokeParticleGroup.dx = cast carBodyGraphics.x + smokeHorizontalOffset * carScale * carBodyAngleCos + smokeVerticalOffset * carScale * carBodyAngleRotatedCos;
		smokeParticleGroup.dy = cast carBodyGraphics.y + smokeHorizontalOffset * carScale * carBodyAngleSin + smokeVerticalOffset * carScale * carBodyAngleRotatedSin;
		smokeParticleGroup.gravityAngle = carBodyGraphics.rotation - Math.PI / 2;
	}

	function updateSpringGraphic()
	{
		frontSpring.x = carBodyGraphics.x + frontSpringHorizontalOffset * carBodyAngleCos + frontSpringVerticalOffset * carBodyAngleRotatedCos;
		frontSpring.y = carBodyGraphics.y + frontSpringHorizontalOffset * carBodyAngleSin + frontSpringVerticalOffset * carBodyAngleRotatedSin;

		backSpring.x = carBodyGraphics.x - backSpringHorizontalOffset * carBodyAngleCos + backSpringVerticalOffset * carBodyAngleRotatedCos;
		backSpring.y = carBodyGraphics.y - backSpringHorizontalOffset * carBodyAngleSin + backSpringVerticalOffset * carBodyAngleRotatedSin;

		if (!isCrushed)
		{
			frontSpring.scaleX = GeomUtil.getDistance(
				{ x: wheelRightGraphics.x, y: wheelRightGraphics.y },
				{ x: frontSpring.x, y: frontSpring.y }
			) / 59;
			frontSpring.rotation = Math.atan2(
				wheelRightGraphics.y - frontSpring.y,
				wheelRightGraphics.x - frontSpring.x
			);

			backSpring.scaleX = GeomUtil.getDistance(
				{ x: wheelLeftGraphics.x, y: wheelLeftGraphics.y },
				{ x: backSpring.x, y: backSpring.y }
			) / 59;
			backSpring.rotation = Math.atan2(
				wheelLeftGraphics.y - backSpring.y,
				wheelLeftGraphics.x - backSpring.x
			);
		}
	}

	function updateWheelHolderGraphic()
	{
		wheelBackTopHolderGraphics.x = carBodyGraphics.x + backTopHolderHorizontalOffset * carBodyAngleCos + backTopHolderVerticalOffset * carBodyAngleRotatedCos;
		wheelBackTopHolderGraphics.y = carBodyGraphics.y + backTopHolderHorizontalOffset * carBodyAngleSin + backTopHolderVerticalOffset * carBodyAngleRotatedSin;


		wheelBackBottomHolderGraphics.x = carBodyGraphics.x + backBottomHolderHorizontalOffset * carBodyAngleCos + backBottomHolderVerticalOffset * carBodyAngleRotatedCos;
		wheelBackBottomHolderGraphics.y = carBodyGraphics.y + backBottomHolderHorizontalOffset * carBodyAngleSin + backBottomHolderVerticalOffset * carBodyAngleRotatedSin;

		wheelFrontTopHolderGraphics.x = carBodyGraphics.x + frontTopHolderHorizontalOffset * carBodyAngleCos + frontTopHolderVerticalOffset * carBodyAngleRotatedCos;
		wheelFrontTopHolderGraphics.y = carBodyGraphics.y + frontTopHolderHorizontalOffset * carBodyAngleSin + frontTopHolderVerticalOffset * carBodyAngleRotatedSin;


		wheelFrontBottomHolderGraphics.x = carBodyGraphics.x + frontBottomHolderHorizontalOffset * carBodyAngleCos + frontBottomHolderVerticalOffset * carBodyAngleRotatedCos;
		wheelFrontBottomHolderGraphics.y = carBodyGraphics.y + frontBottomHolderHorizontalOffset * carBodyAngleSin + frontBottomHolderVerticalOffset * carBodyAngleRotatedSin;

		if (isCrushed)
		{
			wheelBackTopHolderGraphics.rotation = carBodyGraphics.rotation;
			wheelBackBottomHolderGraphics.rotation = carBodyGraphics.rotation + Math.PI;
			wheelFrontTopHolderGraphics.rotation = carBodyGraphics.rotation;
			wheelFrontBottomHolderGraphics.rotation = carBodyGraphics.rotation + Math.PI;
		}
		else
		{
			wheelBackTopHolderGraphics.rotation = Math.atan2(
				wheelLeftGraphics.y - wheelBackTopHolderGraphics.y,
				wheelLeftGraphics.x - wheelBackTopHolderGraphics.x
			);

			wheelBackBottomHolderGraphics.rotation = Math.atan2(
				wheelLeftGraphics.y - wheelBackBottomHolderGraphics.y,
				wheelLeftGraphics.x - wheelBackBottomHolderGraphics.x
			);

			wheelFrontTopHolderGraphics.rotation = Math.atan2(
				wheelRightGraphics.y - wheelFrontTopHolderGraphics.y,
				wheelRightGraphics.x - wheelFrontTopHolderGraphics.x
			);

			wheelFrontBottomHolderGraphics.rotation = Math.atan2(
				wheelRightGraphics.y - wheelFrontBottomHolderGraphics.y,
				wheelRightGraphics.x - wheelFrontBottomHolderGraphics.x
			);
		}
	}

	function get_x():Float
	{
		return carBodyGraphics.x;
	}

	function get_y():Float
	{
		return carBodyGraphics.y;
	}

	public function reset()
	{
		isCrushed = false;

		if (explosionParticleGroup != null)
		{
			particles.removeGroup(explosionParticleGroup);
			explosionParticleGroup.enable = false;
			explosionParticleGroup = null;
		}

		smokeParticleGroup.enable = false;
		particles.removeGroup(smokeParticleGroup);
		Timer.delay(function() {
			if (isEffectEnabled.value)
			{
				smokeParticleGroup.enable = true;
				particles.addGroup(smokeParticleGroup);
			}
		}, 500);
	}

	function get_alpha():Float
	{
		return carBodyGraphics.alpha;
	}

	function set_alpha(value:Float):Float
	{
		carBodyGraphics.alpha = value;
		wheelBackBottomHolderGraphics.alpha = value;
		wheelBackTopHolderGraphics.alpha = value;
		wheelFrontBottomHolderGraphics.alpha = value;
		wheelFrontTopHolderGraphics.alpha = value;
		wheelLeftGraphics.alpha = value;
		wheelRightGraphics.alpha = value;
		backSpring.alpha = value;
		frontSpring.alpha = value;

		return value;
	}
}