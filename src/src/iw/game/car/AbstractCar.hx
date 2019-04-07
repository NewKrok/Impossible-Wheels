package iw.game.car;

import h2d.Bitmap;
import h2d.Layers;
import h2d.Particles;
import haxe.Timer;
import iw.data.CarData;
import hpp.util.GeomUtil;
import hxd.Res;
import tink.state.Observable;

class AbstractCar
{
	var carData:CarData;

	var frontSpringHorizontalOffset:Float = 77;
	var frontSpringVerticalOffset:Float = 1;
	var backSpringHorizontalOffset:Float = 42;
	var backSpringVerticalOffset:Float = 14;
	var backTopHolderHorizontalOffset:Float = 8;
	var backTopHolderVerticalOffset:Float = 45;
	var backBottomHolderHorizontalOffset:Float = 6;
	var backBottomHolderVerticalOffset:Float = 62;
	var frontTopHolderHorizontalOffset:Float = 28;
	var frontTopHolderVerticalOffset:Float = 35;
	var frontBottomHolderHorizontalOffset:Float = 26;
	var frontBottomHolderVerticalOffset:Float = 52;
	var smokeHorizontalOffset:Float = -130;
	var smokeVerticalOffset:Float = 10;
	var rockLeftHorizontalOffset:Float = -100;
	var rockLeftVerticalOffset:Float = 90;
	var rockRightHorizontalOffset:Float = 80;
	var rockRightVerticalOffset:Float = 90;

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

	var carBodyAngleCos:Float = 0;
	var carBodyAngleSin:Float = 0;
	var carBodyAngleRotatedCos:Float = 0;
	var carBodyAngleRotatedSin:Float = 0;

	var particles:Particles;
	var smokeParticleGroup:ParticleGroup;
	var container:Layers;

	var isEffectEnabled:Observable<Bool>;

	public function new(parent:Layers, carData:CarData, scale:Float = 1, isEffectEnabled:Observable<Bool>)
	{
		container = new Layers(parent);
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
	}

	function buildGraphics():Void
	{
		backSpring = new Bitmap(Res.image.car.asset.spring.toTile(), container);
		backSpring.scale(carScale);
		backSpring.smooth = true;
		backSpring.tile.dx = 0;
		backSpring.tile.dy = cast -backSpring.tile.height / 2;

		frontSpring = new Bitmap(Res.image.car.asset.spring.toTile(), container);
		frontSpring.scale(carScale);
		frontSpring.smooth = true;
		frontSpring.tile.dx = 0;
		frontSpring.tile.dy = cast -frontSpring.tile.height / 2;

		carBodyGraphics = new Bitmap(Res.image.car.body.body_a.toTile(), container);
		carBodyGraphics.scale(carScale);
		carBodyGraphics.smooth = true;
		carBodyGraphics.tile.dx = cast -carBodyGraphics.tile.width / 2;
		carBodyGraphics.tile.dy = cast -carBodyGraphics.tile.height / 2;

		wheelBackTopHolderGraphics = new Bitmap(Res.image.car.asset.wheel_holder.toTile(), container);
		wheelBackTopHolderGraphics.scale(carScale);
		wheelBackTopHolderGraphics.smooth = true;
		wheelBackTopHolderGraphics.tile.dx = 0;
		wheelBackTopHolderGraphics.tile.dy = 0;

		wheelBackBottomHolderGraphics = new Bitmap(Res.image.car.asset.wheel_holder.toTile(), container);
		wheelBackBottomHolderGraphics.scale(carScale);
		wheelBackBottomHolderGraphics.smooth = true;
		wheelBackBottomHolderGraphics.tile.dx = 0;
		wheelBackBottomHolderGraphics.tile.dy = 0;

		wheelFrontTopHolderGraphics = new Bitmap(Res.image.car.asset.wheel_holder.toTile(), container);
		wheelFrontTopHolderGraphics.scale(carScale);
		wheelFrontTopHolderGraphics.smooth = true;
		wheelFrontTopHolderGraphics.tile.dx = 0;
		wheelFrontTopHolderGraphics.tile.dy = 0;

		wheelFrontBottomHolderGraphics = new Bitmap(Res.image.car.asset.wheel_holder.toTile(), container);
		wheelFrontBottomHolderGraphics.scale(carScale);
		wheelFrontBottomHolderGraphics.smooth = true;
		wheelFrontBottomHolderGraphics.tile.dx = 0;
		wheelFrontBottomHolderGraphics.tile.dy = 0;

		wheelRightGraphics = new Bitmap(Res.image.car.wheel.wheel_a.toTile(), container);
		wheelRightGraphics.scale(carScale);
		wheelRightGraphics.smooth = true;
		wheelRightGraphics.tile.dx = cast -wheelRightGraphics.tile.width / 2;
		wheelRightGraphics.tile.dy = cast -wheelRightGraphics.tile.height / 2;

		wheelLeftGraphics = new Bitmap(Res.image.car.wheel.wheel_a.toTile(), container);
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
		smokeParticleGroup.speed = 30 * carScale;
		smokeParticleGroup.nparts = 50;
		smokeParticleGroup.emitMode = PartEmitMode.Point;
		smokeParticleGroup.emitDist = 10 * carScale;
		smokeParticleGroup.speedRand = 2;
		smokeParticleGroup.rotSpeed = 3;
		smokeParticleGroup.fadeIn = 0;
		smokeParticleGroup.fadeOut = 0;
		smokeParticleGroup.texture = Res.image.car.asset.smoke.toTexture();
		smokeParticleGroup.rebuildOnChange = false;
		particles.addGroup(smokeParticleGroup);
	}

	public function update(elapsed:Float):Void
	{
		carBodyAngleCos = Math.cos(carBodyGraphics.rotation);
		carBodyAngleSin = Math.sin(carBodyGraphics.rotation);
		carBodyAngleRotatedCos = Math.cos(carBodyGraphics.rotation + Math.PI / 2);
		carBodyAngleRotatedSin = Math.sin(carBodyGraphics.rotation + Math.PI / 2);

		updateSpringGraphic();
		updateWheelHolderGraphic();

		smokeParticleGroup.dx = cast carBodyGraphics.x + smokeHorizontalOffset * carScale * carBodyAngleCos + smokeVerticalOffset * carScale * carBodyAngleRotatedCos;
		smokeParticleGroup.dy = cast carBodyGraphics.y + smokeHorizontalOffset * carScale * carBodyAngleSin + smokeVerticalOffset * carScale * carBodyAngleRotatedSin;
		smokeParticleGroup.gravityAngle = carBodyGraphics.rotation - Math.PI / 2;
	}

	function updateSpringGraphic()
	{
		frontSpring.x = carBodyGraphics.x + frontSpringHorizontalOffset * carBodyAngleCos + frontSpringVerticalOffset * carBodyAngleRotatedCos;
		frontSpring.y = carBodyGraphics.y + frontSpringHorizontalOffset * carBodyAngleSin + frontSpringVerticalOffset * carBodyAngleRotatedSin;
		frontSpring.scaleX = GeomUtil.getDistance(
			{ x: wheelRightGraphics.x, y: wheelRightGraphics.y },
			{ x: frontSpring.x, y: frontSpring.y }
		) / 59;
		frontSpring.rotation = Math.atan2(
			wheelRightGraphics.y - frontSpring.y,
			wheelRightGraphics.x - frontSpring.x
		);

		backSpring.x = carBodyGraphics.x - backSpringHorizontalOffset * carBodyAngleCos + backSpringVerticalOffset * carBodyAngleRotatedCos;
		backSpring.y = carBodyGraphics.y - backSpringHorizontalOffset * carBodyAngleSin + backSpringVerticalOffset * carBodyAngleRotatedSin;
		backSpring.scaleX = GeomUtil.getDistance(
			{ x: wheelLeftGraphics.x, y: wheelLeftGraphics.y },
			{ x: backSpring.x, y: backSpring.y }
		) / 59;
		backSpring.rotation = Math.atan2(
			wheelLeftGraphics.y - backSpring.y,
			wheelLeftGraphics.x - backSpring.x
		);
	}

	function updateWheelHolderGraphic()
	{
		wheelBackTopHolderGraphics.x = carBodyGraphics.x + backTopHolderHorizontalOffset * carBodyAngleCos + backTopHolderVerticalOffset * carBodyAngleRotatedCos;
		wheelBackTopHolderGraphics.y = carBodyGraphics.y + backTopHolderHorizontalOffset * carBodyAngleSin + backTopHolderVerticalOffset * carBodyAngleRotatedSin;
		wheelBackTopHolderGraphics.rotation = Math.atan2(
			wheelLeftGraphics.y - wheelBackTopHolderGraphics.y,
			wheelLeftGraphics.x - wheelBackTopHolderGraphics.x
		);

		wheelBackBottomHolderGraphics.x = carBodyGraphics.x + backBottomHolderHorizontalOffset * carBodyAngleCos + backBottomHolderVerticalOffset * carBodyAngleRotatedCos;
		wheelBackBottomHolderGraphics.y = carBodyGraphics.y + backBottomHolderHorizontalOffset * carBodyAngleSin + backBottomHolderVerticalOffset * carBodyAngleRotatedSin;
		wheelBackBottomHolderGraphics.rotation = Math.atan2(
			wheelLeftGraphics.y - wheelBackBottomHolderGraphics.y,
			wheelLeftGraphics.x - wheelBackBottomHolderGraphics.x
		);

		wheelFrontTopHolderGraphics.x = carBodyGraphics.x + frontTopHolderHorizontalOffset * carBodyAngleCos + frontTopHolderVerticalOffset * carBodyAngleRotatedCos;
		wheelFrontTopHolderGraphics.y = carBodyGraphics.y + frontTopHolderHorizontalOffset * carBodyAngleSin + frontTopHolderVerticalOffset * carBodyAngleRotatedSin;
		wheelFrontTopHolderGraphics.rotation = Math.atan2(
			wheelRightGraphics.y - wheelFrontTopHolderGraphics.y,
			wheelRightGraphics.x - wheelFrontTopHolderGraphics.x
		);

		wheelFrontBottomHolderGraphics.x = carBodyGraphics.x + frontBottomHolderHorizontalOffset * carBodyAngleCos + frontBottomHolderVerticalOffset * carBodyAngleRotatedCos;
		wheelFrontBottomHolderGraphics.y = carBodyGraphics.y + frontBottomHolderHorizontalOffset * carBodyAngleSin + frontBottomHolderVerticalOffset * carBodyAngleRotatedSin;
		wheelFrontBottomHolderGraphics.rotation = Math.atan2(
			wheelRightGraphics.y - wheelFrontBottomHolderGraphics.y,
			wheelRightGraphics.x - wheelFrontBottomHolderGraphics.x
		);
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
}