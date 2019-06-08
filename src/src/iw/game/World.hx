package iw.game;

import apostx.replaykit.Playback;
import apostx.replaykit.Recorder;
import com.greensock.TweenMax;
import com.greensock.easing.Ease;
import com.greensock.easing.Linear;
import com.greensock.easing.Quad;
import h2d.Bitmap;
import h2d.Graphics;
import h2d.Layers;
import h2d.Mask;
import haxe.Timer;
import hpp.heaps.HppG;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import hpp.util.Log;
import hxd.Key;
import hxd.Res;
import iw.data.AssetData;
import iw.data.CarDatas;
import iw.data.LevelData;
import iw.game.TrickCalculator.TrickType;
import iw.game.car.CarLife;
import iw.game.car.PlayerCar;
import iw.game.car.ReplayCar;
import iw.game.constant.CPhysicsValue;
import nape.constraint.PivotJoint;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.space.Space;
import tink.state.Observable;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class World extends Layers
{
	// Enable it to make replays. After focus lost it trace the replay string into console.
	static inline var isRecordingMode:Bool = false;

	public static var WORLD_PIECE_SIZE:SimplePoint = { x: 5000, y: 2000 };
	public static var LEVEL_MAX_TIME:UInt = 5 * 60 * 1000;

	public var onLevelComplete:Void->Void = function(){};
	public var onLoose:Void->Void = function(){};
	public var onLooseLife:Void->Void = function(){};
	public var onTrick:TrickType->Void = function(_){};

	var levelData:LevelData;
	var isEffectEnabled:Observable<Bool>;
	var isCameraEnabled:Observable<Bool>;
	var isControlEnabled:Observable<Bool>;
	var isGameStarted:Observable<Bool>;
	var isGamePaused:Observable<Bool>;
	var isLevelCompleted:Observable<Bool>;
	var isLost:Observable<Bool>;
	var onCoinCollected:Void->Void;

	var camera:Layers;
	var cameraMask:Mask;
	var space:Space;
	var groundBodies:Array<Body>;

	var coins:Array<Coin>;
	var effects:EffectHandler;

	var bridgeBodies:Array<Array<Body>>;
	var bridgeGraphics:Array<Array<Bitmap>>;

	var playerCar:PlayerCar;
	var carLife:CarLife;
	var trickCalculator:TrickCalculator;

	var replayCar:ReplayCar;
	var playback:Playback;
	var recorder:Recorder;
	var replayEndHelper:UInt;

	var cameraEasing:SimplePoint = { x: 15, y: 15 };
	var cameraEasingDuringZoom:SimplePoint = { x: 15, y: 15 };
	var cameraOffset:SimplePoint = { x: -300, y: -300 };
	var cameraZoomHelper:Float = 1;
	var isCameraZoomInProgress:Bool = false;

	var now:Float;

	var buildStep:UInt = 0;

	var buildResult:ActionFlow = { onComplete: null };
	var replayResult:ActionFlow = { onComplete: null };

	var isBuilt:Bool = false;
	var isPhysicsEnabled:Bool = false;
	var isDemo:Bool = false;

	var gameTime:Float = 0;
	var gameStartTime:Float = 0;
	var pauseStartTime:Float = 0;
	var totalPausedTime:Float = 0;

	public function new(
		parent,
		levelData,
		isDemo:Bool,
		isEffectEnabled:Observable<Bool>,
		isGameStarted:Observable<Bool> = null,
		isGamePaused:Observable<Bool> = null,
		isLevelCompleted:Observable<Bool> = null,
		isCameraEnabled:Observable<Bool> = null,
		isControlEnabled:Observable<Bool> = null,
		isLost:Observable<Bool> = null,
		onCoinCollected:Void->Void = null
	){
		super(parent);
		this.levelData = levelData;
		this.isDemo = isDemo;
		this.isEffectEnabled = isEffectEnabled;
		this.isGameStarted = isGameStarted;
		this.isGamePaused = isGamePaused;
		this.isLevelCompleted = isLevelCompleted;
		this.isCameraEnabled = isDemo ? new State<Bool>(false).observe() : isCameraEnabled;
		this.isControlEnabled = isDemo ? new State<Bool>(false).observe() : isControlEnabled;
		this.isLost = isLost;
		this.onCoinCollected = onCoinCollected;

		isGameStarted.bind({ direct: true }, function(v) { if (v) gameStartTime = Date.now().getTime(); });
		isGamePaused.bind(function(v) { if (v) pause(); else resume(); });
	}

	public function build():ActionFlow
	{
		Log.info('Build world, level ${levelData.levelId}');

		var background = new Graphics(this);
		background.beginFill(0xFFFFFF);
		background.drawRect(0, 0, HppG.stage2d.width, HppG.stage2d.height);
		background.endFill();

		cameraMask = new Mask(HppG.stage2d.width, HppG.stage2d.height, this);
		camera = new Layers(cameraMask);

		if (!isDemo) effects = new EffectHandler(camera);

		asyncBuild();

		return buildResult;
	}

	function asyncBuild()
	{
		switch (buildStep)
		{
			case 0:
				createPhysicsWorld();

			case 1:
				for (i in 0...levelData.polygonGroundData.length)
					for (j in 0...levelData.polygonGroundData[i].length)
						for (backgroundData in levelData.polygonGroundData[i][j])
							createGroundPhysics(i, j, backgroundData.polygon);

			case 2:
				if (!isDemo)
				{
					createPlayerCar();

					trickCalculator = new TrickCalculator(playerCar);
					trickCalculator.onTrick = onTrick;
				}
				createReplayCar();

			case 3:
				createBridges();

			case 4:
				createCoins();
				createStaticElements();

			case 5:
				isBuilt = true;

				if (!isDemo)
				{
					isLost.bind(function(v) {
						if (v)
						{
							playerCar.crash();
							cameraEasingDuringZoom.x = 2;
							zoomCamera(1.5, .5);
						}
					});
				}

				reset();

				if (buildResult.onComplete != null) buildResult.onComplete();
				return;
		}

		//levelPreloader.step();
		buildStep++;
		Timer.delay(asyncBuild, 10);
	}

	function createPhysicsWorld():Void
	{
		space = new Space(new Vec2(0, CPhysicsValue.GRAVITY));

		var walls:Body = new Body(BodyType.STATIC);
		walls.shapes.add(new Polygon(Polygon.rect(0, 0, 1, levelData.cameraBounds.height)));
		walls.shapes.add(new Polygon(Polygon.rect(levelData.cameraBounds.width, 0, 1, levelData.cameraBounds.height)));
		walls.space = space;
	}

	function createGroundPhysics(row:UInt, col:UInt, ground:Array<SimplePoint>):Void
	{
		groundBodies = [];

		var filter:InteractionFilter = new InteractionFilter();
		filter.collisionGroup = CPhysicsValue.GROUND_FILTER_CATEGORY;
		filter.collisionMask = CPhysicsValue.GROUND_FILTER_MASK;

		var groundCopy:Array<SimplePoint> = [];

		for (point in ground)
			groundCopy.push({ x: point.x, y: point.y });

		groundCopy.push({ x: ground[0].x, y: ground[0].y });

		for (point in groundCopy)
		{
			point.x += row * WORLD_PIECE_SIZE.x;
			point.y += col * WORLD_PIECE_SIZE.y;
		}

		var g = new Graphics(camera);
		g.smooth = true;
		g.lineStyle(5, 0x000000);

		for (i in 0...groundCopy.length - 1)
		{
			g.moveTo(groundCopy[i].x, groundCopy[i].y);
			g.lineTo(groundCopy[i + 1].x, groundCopy[i + 1].y);

			var angle:Float = Math.atan2(groundCopy[ i + 1 ].y - groundCopy[ i ].y, groundCopy[ i + 1 ].x - groundCopy[ i ].x);
			var distance:Float = Math.sqrt(
				Math.pow(Math.abs(groundCopy[ i + 1 ].x - groundCopy[ i ].x), 2) +
				Math.pow(Math.abs(groundCopy[ i + 1 ].y - groundCopy[ i ].y), 2)
			);

			var body:Body = new Body(BodyType.STATIC);

			body.shapes.add(new Polygon(Polygon.box(distance, 1)));
			body.setShapeMaterials(Material.wood());
			body.setShapeFilters(filter);
			body.position.x = groundCopy[ i ].x + (groundCopy[ i + 1 ].x - groundCopy[ i ].x) / 2;
			body.position.y = groundCopy[ i ].y + (groundCopy[ i + 1 ].y - groundCopy[ i ].y) / 2;
			body.rotation = angle;

			body.space = space;

			groundBodies.push(body);
		}

		g.endFill();
	}

	function createPlayerCar():Void
	{
		playerCar = new PlayerCar(
			camera,
			space,
			levelData.startPoint.x,
			levelData.startPoint.y,
			CarDatas.getData(0),
			.5,
			isEffectEnabled,
			CPhysicsValue.CAR_FILTER_CATEGORY,
			CPhysicsValue.CAR_FILTER_MASK
		);
		playerCar.teleportTo(levelData.startPoint.x, levelData.startPoint.y);

		carLife = new CarLife();
	}

	function createReplayCar():Void
	{
		replayCar = new ReplayCar(camera, CarDatas.getData(0), .5, isEffectEnabled);
	}

	function createBridges():Void
	{
		bridgeBodies = [];
		bridgeGraphics = [];

		for (i in 0...levelData.bridgePoints.length)
		{
			createBridge(
				{ x: levelData.bridgePoints[i].bridgeAX, y: levelData.bridgePoints[i].bridgeAY },
				{ x: levelData.bridgePoints[i].bridgeBX, y: levelData.bridgePoints[i].bridgeBY }
			);
		}
	}

	function createBridge(pointA:SimplePoint, pointB:SimplePoint):Void
	{
		var filter:InteractionFilter = new InteractionFilter();
		filter.collisionGroup = CPhysicsValue.BRIDGE_FILTER_CATEGORY;
		filter.collisionMask = CPhysicsValue.BRIDGE_FILTER_MASK;

		var bridgeAngle:Float = Math.atan2(pointB.y - pointA.y, pointB.x - pointA.x);
		var bridgeElementWidth:UInt = 60;
		var bridgeElementHeight:UInt = 25;
		var anchorA:Vec2 = new Vec2(bridgeElementWidth / 2, 0);
		var anchorB:Vec2 = new Vec2(-bridgeElementWidth / 2, 0);
		var bridgeDistance:Float = GeomUtil.getDistance(pointA, pointB);
		var pieces:UInt = Math.round(bridgeDistance / bridgeElementWidth) + 1;

		if (bridgeDistance % bridgeElementWidth == 0)
		{
			pieces++;
		}

		bridgeGraphics.push([]);
		bridgeBodies.push([]);

		for (i in 0...pieces)
		{
			var isLockedBridgeElement:Bool = false;
			if (i == 0 || i == cast(pieces - 1))
			{
				isLockedBridgeElement = true;
			}

			var body:Body = new Body(isLockedBridgeElement ? BodyType.STATIC : BodyType.DYNAMIC);
			body.shapes.add(new Polygon(Polygon.box(bridgeElementWidth, bridgeElementHeight)));
			body.setShapeMaterials(Material.wood());
			body.setShapeFilters(filter);
			body.allowRotation = !isLockedBridgeElement;
			body.position.x = pointA.x + i * bridgeElementWidth * Math.cos(bridgeAngle);
			body.position.y = pointA.y + i * bridgeElementWidth * Math.sin(bridgeAngle);
			body.rotation = bridgeAngle;
			body.space = space;
			bridgeBodies[bridgeBodies.length - 1].push(body);

			var bridge = new Bitmap(Res.image.game_asset.bridge.toTile(), camera);
			bridge.smooth = true;
			bridge.tile.dx = cast -bridge.tile.width / 2;
			bridge.tile.dy = cast -bridge.tile.height / 2;
			bridgeGraphics[bridgeGraphics.length - 1].push(bridge);

			if (i > 0)
			{
				var pivotJointLeftLeftWheel:PivotJoint = new PivotJoint(bridgeBodies[bridgeBodies.length - 1][i - 1], bridgeBodies[bridgeBodies.length - 1][i], anchorA, anchorB);
				pivotJointLeftLeftWheel.damping = 1;
				pivotJointLeftLeftWheel.frequency = 20;
				pivotJointLeftLeftWheel.space = space;
			}
		}
	}

	function createCoins()
	{
		coins = [];

		for (c in levelData.collectableItems)
		{
			var coin = new Coin(camera);
			coin.x = c.x;
			coin.y = c.y;
			coins.push(coin);
		}
	}

	function createStaticElements()
	{
		for (e in levelData.staticElementData)
		{
			var img = AssetData.getBitmap(e.elementId, camera);
			img.tile.dx = cast -e.pivotX;
			img.tile.dy = cast -e.pivotY;
			img.x = e.position.x;
			img.y = e.position.y;
			img.rotation = e.rotation;
			img.scaleX = e.scaleX;
			img.scaleY = e.scaleY;
		}
	}

	public function playReplay(replayData:String):ActionFlow
	{
		destroyPlayback();

		gameStartTime = now;
		totalPausedTime = 0;

		playback = new Playback(replayCar, replayData);
		playback.showSnapshot(0);

		return replayResult;
	}

	public function jumpCameraTo(x:Float, y:Float):Void
	{
		TweenMax.killTweensOf(camera);

		if (playerCar != null)
		{
			x += cameraOffset.x;
			y += cameraOffset.y;
		}

		camera.x = -x;
		camera.y = -y;
	}

	public function moveCameraTo(x:Float, y:Float, time:Float):ActionFlow
	{
		var result:ActionFlow = { onComplete: null };

		if (playerCar != null)
		{
			x += cameraOffset.x;
			y += cameraOffset.y;
		}

		TweenMax.killTweensOf(camera);
		TweenMax.to(camera, time, {
			x: -x,
			y: -y,
			onUpdate: function() { camera.x = camera.x; }, // To solve Tween/Heaps bug
			onComplete: function() { if (result.onComplete != null) result.onComplete(); }
		});

		return result;
	}

	public function zoomCamera(scale:Float, time:Float, ease:Ease = null):ActionFlow
	{
		var result:ActionFlow = { onComplete: null };

		if (ease == null) ease = Linear.easeNone;

		isCameraZoomInProgress = true;
		TweenMax.killTweensOf(this);
		TweenMax.to(this, time, {
			cameraZoomHelper: scale,
			onUpdate: function() {
				camera.setScale(cameraZoomHelper);
			},
			onComplete: function()
			{
				isCameraZoomInProgress = false;
				if (result.onComplete != null) result.onComplete();
			},
			ease: ease
		});

		if (time == 0)
		{
			cameraZoomHelper = scale;
			camera.setScale(cameraZoomHelper);
		}

		return result;
	}

	public function reset()
	{
		gameTime = 0;
		totalPausedTime = 0;
		pauseStartTime = 0;
		now = Date.now().getTime();

		if (isRecordingMode)
		{
			destroyRecorder();
			recorder = new Recorder(playerCar);
			recorder.enableAutoRecording(50);
		}
		replayEndHelper = 0;

		if (!isDemo)
		{
			for ( c in coins) c.reset();

			trickCalculator.reset();

			playerCar.teleportTo(
				levelData.startPoint.x,
				levelData.startPoint.y
			);

			carLife.reset();

			cameraEasingDuringZoom.x = 10;
			cameraEasingDuringZoom.y = 10;
			zoomCamera(1.5, 0);
			zoomCamera(1, 1, Quad.easeOut);

			effects.reset();
		}

		resume();
	}

	public function update(delta:Float)
	{
		if (!isBuilt) return;

		if (Key.isDown(Key.Z) && Key.isPressed(Key.NUMBER_1)) zoomCamera(.15, 1);
		if (Key.isDown(Key.Z) && Key.isPressed(Key.NUMBER_2)) zoomCamera(.25, 1);
		if (Key.isDown(Key.Z) && Key.isPressed(Key.NUMBER_3)) zoomCamera(.5, 1);
		if (Key.isDown(Key.Z) && Key.isPressed(Key.NUMBER_4)) zoomCamera(1, 1);
		if (Key.isDown(Key.Z) && Key.isPressed(Key.NUMBER_5)) zoomCamera(1.5, 1);
		if (Key.isDown(Key.Z) && Key.isPressed(Key.NUMBER_6)) zoomCamera(2, 1);

		now = Date.now().getTime();
		if (isGamePaused.value) return;

		if (isDemo || (isLevelCompleted != null && !isLevelCompleted.value)) calculateGameTime();

		if (isPhysicsEnabled) space.step(CPhysicsValue.STEP);

		updateBridges();

		if (!isDemo)
		{
			playerCar.update(delta);

			if (!isLost.value && isControlEnabled.value)
			{
				if (Key.isDown(Key.UP)) playerCar.accelerateToRight();
				else if (Key.isDown(Key.DOWN)) playerCar.accelerateToLeft();

				if (Key.isDown(Key.LEFT)) playerCar.rotateLeft();
				else if (Key.isDown(Key.RIGHT)) playerCar.rotateRight();

				trickCalculator.update(gameTime);
				checkCoinPickUp();

				checkLevelComplete();
				checkLife();
				checkLoose();
			}

			if (isCameraEnabled.value)
			{
				var cameraPointX = -playerCar.x - cameraOffset.x * (1 / camera.scaleX);
				cameraPointX *= camera.scaleX;
				var cameraPointY = -playerCar.y - cameraOffset.y * (1 / camera.scaleY);
				cameraPointY *= camera.scaleY;

				camera.x -= (camera.x - cameraPointX) / (isCameraZoomInProgress ? cameraEasingDuringZoom.x : cameraEasing.x);
				camera.y -= (camera.y - cameraPointY) / (isCameraZoomInProgress ? cameraEasingDuringZoom.y : cameraEasing.y);
			}
		}

		if (playback != null)
		{
			var tempX = replayCar.carBodyGraphics.x;
			var tempY = replayCar.carBodyGraphics.y;
			var tempRotation = replayCar.carBodyGraphics.rotation;

			playback.showSnapshot(gameTime);
			replayCar.update(delta);

			// Not the best detection but there is no way to detect it with Playback
			if (
				tempX == replayCar.carBodyGraphics.x
				&& tempY == replayCar.carBodyGraphics.y
				&& tempRotation == replayCar.carBodyGraphics.rotation
				&& replayResult.onComplete != null
			) {
				replayEndHelper++;
				if (replayEndHelper > 10) replayResult.onComplete();
			}
			else replayEndHelper = 0;
		}
	}

	function calculateGameTime():Void
	{
		if (isGameStarted.value) gameTime = now - gameStartTime - totalPausedTime;
		else gameTime = 0;
	}

	function updateBridges():Void
	{
		for (i in 0...bridgeBodies.length)
		{
			for (j in 0...bridgeGraphics[i].length)
			{
				var graphic:Bitmap = bridgeGraphics[i][j];
				var body:Body = bridgeBodies[i][j];

				graphic.x = body.position.x;
				graphic.y = body.position.y;
				graphic.rotation = body.rotation;
			}
		}
	}

	function checkCoinPickUp():Void
	{
		var backWheelMidPoint:SimplePoint = cast playerCar.wheelLeftGraphics;
		var frontWheelMidPoint:SimplePoint = cast playerCar.wheelRightGraphics;

		var bodyCos = Math.cos(playerCar.carBodyGraphics.rotation - Math.PI / 2);
		var bodySin = Math.sin(playerCar.carBodyGraphics.rotation - Math.PI / 2);
		var backBodyMidPoint:SimplePoint = GeomUtil.cloneSimplePoint(backWheelMidPoint);
		backBodyMidPoint.x += 30 * bodyCos;
		backBodyMidPoint.y += 30 * bodySin;
		var frontBodyMidPoint:SimplePoint = GeomUtil.cloneSimplePoint(frontWheelMidPoint);
		frontBodyMidPoint.x += 30 * bodyCos;
		frontBodyMidPoint.y += 30 * bodySin;

		for (c in coins)
		{
			var coinMidPoint:SimplePoint = cast c;

			if (
				!c.isCollected
				&& (
					GeomUtil.getDistance(cast c, cast frontWheelMidPoint) < 35
					|| GeomUtil.getDistance(cast c, cast backWheelMidPoint) < 35
					|| GeomUtil.getDistance(cast c, cast frontBodyMidPoint) < 35 // simple check for body collision
					|| GeomUtil.getDistance(cast c, cast backBodyMidPoint) < 35 // simple check for body collision
				)
			){
				c.collect();
				if (isEffectEnabled.value) effects.addCollectCoinEffect(c.x, c.y - 90);
				onCoinCollected();
			}
		}
	}

	function checkLevelComplete():Void
	{
		if (GeomUtil.getDistance(cast levelData.finishPoint, cast playerCar.wheelRightGraphics) < 20) onLevelComplete();
	}

	function checkLife()
	{
		if (!carLife.isInvulnerable && playerCar.isCarBodyTouchGround && gameTime > 1000)
		{
			SoundManager.playLooseLifeSound();
			carLife.damage();
			onLooseLife();

			for (i in 0...6) TweenMax.delayedCall(i * .1, function(){ playerCar.alpha = playerCar.alpha == 1 ? .5 : 1; });
		}
	}

	function checkLoose():Void
	{
		var isTimeout:Bool = gameTime >= LEVEL_MAX_TIME;
		var isFallDown:Bool = playerCar.carBodyGraphics.y > levelData.cameraBounds.y + levelData.cameraBounds.height;

		if (isTimeout || isFallDown) onLoose();
	}

	public function getGameTime():Float return gameTime;

	function pause()
	{
		isPhysicsEnabled = false;

		if (pauseStartTime != 0) totalPausedTime += now - pauseStartTime;
		pauseStartTime = now;

		if (isRecordingMode && recorder != null)
		{
			recorder.pause();
			recorder.takeSnapshot();
			trace(recorder.toString());
		}
		else if (playerCar != null) trace("Car current position:", Math.floor(playerCar.wheelRightGraphics.x), Math.floor(playerCar.wheelRightGraphics.y));

		if (coins != null) for (c in coins) c.pause();
	}

	function resume()
	{
		isPhysicsEnabled = true;

		if (pauseStartTime != 0 && isGameStarted.value) totalPausedTime += now - pauseStartTime;
		pauseStartTime = 0;

		if (recorder != null) recorder.resume();

		if (coins != null) for (c in coins) c.resume();
	}

	public function destroy()
	{
		TweenMax.killTweensOf(cameraZoomHelper);
		TweenMax.killTweensOf(camera);

		if (!isDemo)
		{
			carLife.destroy();
		}

		destroyPlayback();
		destroyRecorder();
	}

	function destroyPlayback()
	{
		if (playback != null)
		{
			playback.dispose();
			playback = null;
		}
	}

	function destroyRecorder()
	{
		if (recorder != null)
		{
			recorder.dispose();
			recorder = null;
		}
	}
}

typedef ActionFlow = {
	var onComplete:Void->Void;
}