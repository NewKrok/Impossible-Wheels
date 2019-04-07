package iw.game.car;

import apostx.replaykit.IRecorderPerformer;
import h2d.Bitmap;
import h2d.Layers;
import h2d.Sprite;
import haxe.Serializer;
import iw.data.CarData;
import iw.data.CarData.CarLeveledData;
import iw.data.CarDatas;
import hpp.util.GeomUtil;
import nape.callbacks.InteractionType;
import nape.constraint.DistanceJoint;
import nape.constraint.PivotJoint;
import nape.constraint.WeldJoint;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyList;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.space.Space;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class PlayerCar extends AbstractCar implements IRecorderPerformer
{
	var carLeveledData:CarLeveledData;

	var wheelJoinDamping:Float = .4;
	var wheelJoinHertz:Float = 4;

	var firstWheelXOffset:Float = 55;
	var firstWheelYOffset:Float = 35;
	var firstWheelRadius:Float = 40;
	var backWheelXOffset:Float = -52;
	var backWheelYOffset:Float = 35;
	var backWheelRadius:Float = 40;
	var bodyWidth:Float = 150;
	var bodyHeight:Float = 45;
	var hitAreaHeight:Float = 10;

	var flagJoinDamping:Float = .15;
	var flagJoinHertz:Float = 1.5;

	var flagEndPointXOffet:Float = -115;
	var flagEndPointYOffet:Float = -72;
	var flagGraphicXOffset:Float = -55;
	var flagGraphicYOffset:Float = -20;
	var flagAngleOffset:Float = 145;

	var hitArea:Body;
	public var carBodyPhysics:Body;
	public var wheelRightPhysics:Body;
	public var wheelLeftPhysics:Body;
	public var flagPhysics:Body;

	//public var flagGraphic:FlxSprite;

	public var isOnWheelie:Bool;
	public var onWheelieStartGameTime:Float;

	public var isOnAir:Bool;
	public var onAirStartGameTime:Float;
	public var jumpAngle:Float = 0;
	public var lastAngleOnGround:Float = 0;
	public var isHorizontalMoveDisabled:Bool = false;

	public var leftWheelOnAir(default, null):Bool;
	public var rightWheelOnAir(default, null):Bool;
	public var isCarCrashed(default, null):Bool;

	var carAngleCos(default, null):Float = 0;
	var carAngleSin(default, null):Float = 0;
	var carAngleRotatedCos(default, null):Float = 0;
	var carAngleRotatedSin(default, null):Float = 0;

	var direction:Int = 1;
	var space:Space;
	var hasFlag:Bool;

	public function new(parent:Layers, space:Space, x:Float, y:Float, carData:CarData, carScale:Float = 1, isEffectEnabled:Observable<Bool>, filterCategory:UInt = 0, filterMask:UInt = 0)
	{
		//hasFlag = carData.flagGraphic != null && carData.flagGraphic != "";

		super(parent, carData, carScale, isEffectEnabled);
		carLeveledData = CarDatas.getLeveledData(carData.id);

		this.space = space;

		firstWheelXOffset += Math.isNaN(carData.firstWheelXOffset) ? 0 : carData.firstWheelXOffset;
		firstWheelYOffset += Math.isNaN(carData.firstWheelYOffset) ? 0 : carData.firstWheelYOffset;
		backWheelXOffset += Math.isNaN(carData.backWheelXOffset) ? 0 : carData.backWheelXOffset;
		backWheelYOffset += Math.isNaN(carData.backWheelYOffset) ? 0 : carData.backWheelYOffset;

		firstWheelXOffset *= carScale;
		firstWheelYOffset *= carScale;
		firstWheelRadius *= carScale;
		backWheelXOffset *= carScale;
		backWheelYOffset *= carScale;
		backWheelRadius *= carScale;
		bodyWidth *= carScale;
		bodyHeight *= carScale;
		hitAreaHeight *= carScale;

		flagEndPointXOffet *= carScale;
		flagEndPointYOffet *= carScale;

		buildPhysics(x, y, filterCategory, filterMask);
	}

	override function buildGraphics():Void
	{
		/*if (hasFlag)
		{
			add(flagGraphic = HPPAssetManager.getSprite(carData.flagGraphic));
			flagGraphic.antialiasing = true;
			flagGraphic.scale = new FlxPoint(carScale, carScale);
			flagGraphic.origin.set(flagGraphic.width, flagGraphic.height);
		}*/

		super.buildGraphics();
	}

	function buildPhysics(x:Float, y:Float, filterCategory:Int = 0, filterMask:Int = 0):Void
	{
		var filter = new InteractionFilter();
		filter.collisionGroup = filterCategory;
		filter.collisionMask = filterMask;

		var noHitFilter = new InteractionFilter();
		noHitFilter.collisionGroup = 0;
		noHitFilter.collisionMask = 0;

		wheelRightPhysics = new Body();
		wheelRightPhysics.shapes.add(new Circle(firstWheelRadius, null, new Material(0.1,1.0,1.4,1.5,0.01)));
		wheelRightPhysics.setShapeFilters(filter);
		wheelRightPhysics.position.x = x + firstWheelXOffset;
		wheelRightPhysics.position.y = y + firstWheelYOffset;
		wheelRightPhysics.space = space;
		wheelRightPhysics.mass = 1;

		wheelLeftPhysics = new Body();
		wheelLeftPhysics.shapes.add(new Circle(firstWheelRadius, null, new Material(0.1,1.0,1.4,1.5,0.01)));
		wheelLeftPhysics.setShapeFilters(filter);
		wheelLeftPhysics.position.x = x + backWheelXOffset;
		wheelLeftPhysics.position.y = y + backWheelYOffset;
		wheelLeftPhysics.space = space;
		wheelRightPhysics.mass = 1;

		if (hasFlag)
		{
			flagPhysics = new Body();
			flagPhysics.shapes.add(new Circle(5));
			flagPhysics.setShapeFilters(noHitFilter);
			flagPhysics.position.x = x + flagEndPointXOffet;
			flagPhysics.position.y = y + flagEndPointYOffet;
			flagPhysics.space = space;
			flagPhysics.mass = 0.001;
		}

		carBodyPhysics = new Body();
		carBodyPhysics.shapes.add(new Polygon(Polygon.box(bodyWidth, bodyHeight)));
		carBodyPhysics.setShapeFilters(filter);
		carBodyPhysics.position.x = x;
		carBodyPhysics.position.y = y;
		carBodyPhysics.space = space;
		carBodyPhysics.mass = 1;

		hitArea = new Body();
		hitArea.shapes.add(new Polygon(Polygon.box(bodyWidth * .7, hitAreaHeight)));
		hitArea.setShapeFilters(filter);
		hitArea.space = space;
		hitArea.mass = 1;

		var hitAreaAnchor:Vec2 = new Vec2(0, bodyHeight / 2 + hitAreaHeight / 2);
		var hitJoin:WeldJoint = new WeldJoint(carBodyPhysics, hitArea, carBodyPhysics.localCOM, hitAreaAnchor);
		hitJoin.space = space;

		var bodyLeftAnchor:Vec2 = new Vec2(backWheelXOffset, backWheelYOffset);
		var pivotJointLeftLeftWheel:PivotJoint = new PivotJoint(wheelLeftPhysics, carBodyPhysics, wheelLeftPhysics.localCOM, bodyLeftAnchor);
		pivotJointLeftLeftWheel.stiff = false;
		pivotJointLeftLeftWheel.damping = wheelJoinDamping;
		pivotJointLeftLeftWheel.frequency = wheelJoinHertz;
		pivotJointLeftLeftWheel.space = space;

		var bodyRightAnchor:Vec2 = new Vec2(firstWheelXOffset, firstWheelYOffset);
		var pivotJointRightRightWheel:PivotJoint = new PivotJoint(wheelRightPhysics, carBodyPhysics, wheelRightPhysics.localCOM, bodyRightAnchor);
		pivotJointRightRightWheel.stiff = false;
		pivotJointRightRightWheel.damping = wheelJoinDamping;
		pivotJointRightRightWheel.frequency = wheelJoinHertz;
		pivotJointRightRightWheel.space = space;

		var distance:Float = firstWheelXOffset + Math.abs(backWheelXOffset);
		var wheelJoin:DistanceJoint = new DistanceJoint(wheelRightPhysics, wheelLeftPhysics, wheelRightPhysics.localCOM, wheelLeftPhysics.localCOM, distance, distance);
		wheelJoin.space = space;

		if (hasFlag)
		{
			var flagWeldAnchorA:Vec2 = new Vec2( flagEndPointXOffet * carScale - 20 * carScale, flagEndPointYOffet * carScale );
			var flagFrontJointWheel:PivotJoint = new PivotJoint(carBodyPhysics, flagPhysics, flagWeldAnchorA, flagPhysics.localCOM);
			flagFrontJointWheel.stiff = false;
			flagFrontJointWheel.damping = flagJoinDamping;
			flagFrontJointWheel.frequency = flagJoinHertz;
			flagFrontJointWheel.space = space;

			var flagWeldAnchorB:Vec2 = new Vec2( flagEndPointXOffet * carScale, flagEndPointYOffet * carScale );
			var flagFrontJointWheel:PivotJoint = new PivotJoint(carBodyPhysics, flagPhysics, flagWeldAnchorB, flagPhysics.localCOM);
			flagFrontJointWheel.stiff = false;
			flagFrontJointWheel.damping = flagJoinDamping;
			flagFrontJointWheel.frequency = flagJoinHertz;
			flagFrontJointWheel.space = space;
		}
	}

	public function getMidXPosition():Float
	{
		return carBodyGraphics.x;
	}

	public function getMidYPosition():Float
	{
		return carBodyGraphics.y;
	}

	override public function update(elapsed:Float):Void
	{
		if (isHorizontalMoveDisabled)
		{
			carBodyPhysics.velocity.x = 0;
			wheelLeftPhysics.velocity.x = 0;
			wheelRightPhysics.velocity.x = 0;
		}

		carAngleCos = Math.cos(carBodyPhysics.rotation);
		carAngleSin = Math.sin(carBodyPhysics.rotation);
		carAngleRotatedCos = Math.cos(carBodyPhysics.rotation + Math.PI / 2);
		carAngleRotatedSin = Math.sin(carBodyPhysics.rotation + Math.PI / 2);

		updateMainCarComponnentGraphic();

		//if (hasFlag) updateFlagGraphic();

		calculateCollision();

		super.update(elapsed);
	}

	function updateMainCarComponnentGraphic()
	{
		carBodyGraphics.x = carBodyPhysics.position.x;
		carBodyGraphics.y = carBodyPhysics.position.y;
		carBodyGraphics.rotation = carBodyPhysics.rotation;

		wheelRightGraphics.x = wheelRightPhysics.position.x;
		wheelRightGraphics.y = wheelRightPhysics.position.y;
		wheelRightGraphics.rotation = wheelRightPhysics.rotation;

		wheelLeftGraphics.x = wheelLeftPhysics.position.x;
		wheelLeftGraphics.y = wheelLeftPhysics.position.y;
		wheelLeftGraphics.rotation = wheelLeftPhysics.rotation;
	}

	/*function updateFlagGraphic()
	{
		flagGraphic.x = carBodyPhysics.position.x - flagGraphic.origin.x + flagGraphicXOffset * carAngleCos + flagGraphicYOffset * carAngleRotatedCos;
		flagGraphic.y = carBodyPhysics.position.y - flagGraphic.origin.y + flagGraphicXOffset * carAngleSin + flagGraphicYOffset * carAngleRotatedSin;

		flagGraphic.angle = flagAngleOffset + FlxAngle.TO_DEG * (GeomUtil.getAngle(
			{
				x: flagGraphic.x + flagGraphic.origin.x,
				y: flagGraphic.y + flagGraphic.origin.y
			},
			{
				x: flagPhysics.position.x,
				y: flagPhysics.position.y
			}
		));
	}*/

	function calculateCollision():Void
	{
		var contactList:BodyList = wheelLeftPhysics.interactingBodies();
		leftWheelOnAir = true;

		while (!contactList.empty())
		{
			var obj:Body = contactList.pop();
			if (obj != carBodyPhysics)
			{
				leftWheelOnAir = false;
				break;
			}
		}

		contactList = wheelRightPhysics.interactingBodies();
		rightWheelOnAir = true;

		while (!contactList.empty())
		{
			var obj:Body = contactList.pop();
			if (obj != carBodyPhysics)
			{
				rightWheelOnAir = false;
				break;
			}
		}

		contactList = hitArea.interactingBodies(InteractionType.COLLISION, 1);
		isCarCrashed = false;

		while (!contactList.empty())
		{
			var obj:Body = contactList.pop();
			if (obj != carBodyPhysics && obj != wheelLeftPhysics && obj != wheelRightPhysics)
			{
				isCarCrashed = true;
				break;
			}
		}
	}

	public function accelerateToLeft():Void
	{
		direction = -1;

		wheelLeftPhysics.angularVel = -carLeveledData.speed / 2;
		wheelRightPhysics.angularVel = -carLeveledData.speed / 2;
	}

	public function accelerateToRight():Void
	{
		direction = 1;

		wheelLeftPhysics.angularVel = carLeveledData.speed;
		wheelRightPhysics.angularVel = carLeveledData.speed;
	}

	public function idle():Void
	{
	}

	public function rotateLeft():Void
	{
		carBodyPhysics.applyAngularImpulse(-carLeveledData.rotation);
	}

	public function rotateRight():Void
	{
		carBodyPhysics.applyAngularImpulse(carLeveledData.rotation);
	}

	public function teleportTo(x:Float, y:Float):Void
	{
		carBodyPhysics.position.x = x;
		carBodyPhysics.position.y = y;
		carBodyPhysics.rotation = 0;
		carBodyPhysics.velocity.setxy(0, 0);
		carBodyPhysics.angularVel = 0;

		wheelRightPhysics.position.x = x + firstWheelXOffset;
		wheelRightPhysics.position.y = y + firstWheelYOffset;
		wheelRightPhysics.rotation = 0;
		wheelRightPhysics.velocity.setxy(0, 0);
		wheelRightPhysics.angularVel = 0;

		wheelLeftPhysics.position.x = x + backWheelXOffset;
		wheelLeftPhysics.position.y = y + backWheelYOffset;
		wheelLeftPhysics.rotation = 0;
		wheelLeftPhysics.velocity.setxy(0, 0);
		wheelLeftPhysics.angularVel = 0;

		hitArea.position.x = x;
		hitArea.position.y = y + bodyHeight / 2 + hitAreaHeight / 2;
		hitArea.rotation = 0;
		hitArea.velocity.setxy(0, 0);
		hitArea.angularVel = 0;

		if (hasFlag)
		{
			flagPhysics.position.x = x + flagEndPointXOffet;
			flagPhysics.position.y = y + flagEndPointYOffet;
			flagPhysics.velocity.setxy(0, 0);
		}

		reset();
		update(0);
	}

	public function serialize(s:Serializer):Void
	{
		serializeSprite(s, carBodyGraphics);
		serializeSprite(s, wheelRightGraphics);
		serializeSprite(s, wheelLeftGraphics);
	}

	private function serializeSprite(s:Serializer, sprite:Bitmap):Void
	{
		s.serialize(Math.round(sprite.x));
		s.serialize(Math.round(sprite.y));
		s.serialize(Math.round(sprite.rotation * 100) / 100);
	}
}