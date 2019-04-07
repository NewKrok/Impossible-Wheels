package iw.game;

import apostx.replaykit.Playback;
import apostx.replaykit.Recorder;
import com.greensock.TweenMax;
import h2d.Graphics;
import h2d.Layers;
import haxe.Timer;
import iw.data.CarDatas;
import iw.data.LevelData;
import iw.game.car.PlayerCar;
import iw.game.car.ReplayCar;
import iw.game.constant.CPhysicsValue;
import hpp.heaps.HppG;
import hpp.util.GeomUtil.SimplePoint;
import hpp.util.Log;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.space.Space;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class World extends Layers
{
	// Enable it to make replays. After focus lost it trace the replay string into console.
	static inline var isRecordingMode:Bool = false;

	public static var WORLD_PIECE_SIZE:SimplePoint = { x: 5000, y: 2000 };

	var levelData:LevelData;
	var isEffectEnabled:Observable<Bool>;

	var camera:Layers;
	var space:Space;
	var groundBodies:Array<Body>;

	var playerCar:PlayerCar;

	var replayCar:ReplayCar;
	var playback:Playback;
	var recorder:Recorder;

	var cameraEasing:SimplePoint = { x: 15, y: 15 };
	var cameraOffset:SimplePoint = { x: 300, y: 300 };
	var cameraZoomHelper:Float = 1;

	var now:Float;

	var buildStep:UInt = 0;

	var buildResult:ActionFlow = { onComplete: null };
	var replayResult:ActionFlow = { onComplete: null };

	/*var isLost:Bool = false;
	var isWon:Bool = false;
	var isLevelFinished:Bool = false;
	var canControll:Bool = false;*/
	var isGameStarted:Bool = false;
	//var isRaceStarted:Bool = false;
	var isGamePaused:Bool = false;
	/*var isDemoFinished:Bool = false;
	var isMenuMode:Bool = true;
	var isRecordingMode:Bool = true;*/
	var isBuilt:Bool = false;
	var isPhysicsEnabled:Bool = false;
	var isDemo:Bool = false;

	var gameTime:Float = 0;
	var gameStartTime:Float = 0;
	var pauseStartTime:Float = 0;
	var totalPausedTime:Float = 0;

	public function new(parent, levelData, isDemo:Bool, isEffectEnabled:Observable<Bool>)
	{
		super(parent);
		this.levelData = levelData;
		this.isDemo = isDemo;
		this.isEffectEnabled = isEffectEnabled;
	}

	public function build():ActionFlow
	{
		Log.info('Build world, level ${levelData.levelId}');

		var background = new Graphics(this);
		background.beginFill(0xFFFFFF);
		background.drawRect(0, 0, HppG.stage2d.width, HppG.stage2d.height);
		background.endFill();

		camera = new Layers(this);

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
				if (!isDemo) createPlayerCar();
				createReplayCar();

			case 3:
				isBuilt = true;
				reset();

				if (buildResult.onComplete != null) buildResult.onComplete();
				return;

			case 4:
				/*createBridges();

			case 5:
				/*createCoins();
				createLibraryElements();

				add(gameGui = new GameGui(resume, pauseRequest, levelData.collectableItems.length));*/

			case 6:
				//levelPreloader.hide(removePreloader);
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
	}

	function createReplayCar():Void
	{
		replayCar = new ReplayCar(camera, CarDatas.getData(0), .5, isEffectEnabled);
	}

	public function playReplay(replayData:String):ActionFlow
	{
		destroyPlayback();

		playback = new Playback(replayCar, replayData);
		playback.showSnapshot(0);

		return replayResult;
	}

	public function jumpCameraTo(x:Float, y:Float):Void
	{
		TweenMax.killTweensOf(camera);

		camera.x = -x;
		camera.y = -y;
	}

	public function moveCameraTo(x:Float, y:Float, time:Float):ActionFlow
	{
		var result:ActionFlow = { onComplete: null };

		TweenMax.killTweensOf(camera);
		TweenMax.to(camera, time, {
			x: -x,
			y: -y,
			onUpdate: function() { camera.x = camera.x; }, // To solve Tween/Heaps bug
			onComplete: function() { if (result.onComplete != null) result.onComplete(); }
		});

		return result;
	}

	public function zoomCamera(scale:Float, time:Float):ActionFlow
	{
		var result:ActionFlow = { onComplete: null };

		TweenMax.killTweensOf(cameraZoomHelper);
		TweenMax.to(this, time, {
			cameraZoomHelper: scale,
			onUpdate: function() { camera.setScale(cameraZoomHelper); },
			onComplete: function() { if (result.onComplete != null) result.onComplete(); }
		});

		return result;
	}

	public function reset()
	{
		isGameStarted = true;
		/*isRaceStarted = false;
		isGamePaused = false;
		isCameraAllowed = true;
		isDemoFinished = false;*/

		gameTime = 0;
		totalPausedTime = 0;
		pauseStartTime = 0;
		now = gameStartTime = Date.now().getTime();

		if (isRecordingMode)
		{
			destroyRecorder();
			recorder = new Recorder(playerCar);
			recorder.enableAutoRecording(100);
		}

		resume();
	}

	public function update(delta:Float)
	{
		now = Date.now().getTime();
		if (isGamePaused) return;

		calculateGameTime();

		if (isPhysicsEnabled) space.step(CPhysicsValue.STEP);

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
				replayResult.onComplete();
			}
		}
	}

	function calculateGameTime():Void
	{
		if (isGameStarted) gameTime = now - gameStartTime - totalPausedTime;
		else gameTime = 0;
	}

	public function pause()
	{
		isPhysicsEnabled = false;
		isGamePaused = true;

		if (pauseStartTime != 0) totalPausedTime += now - pauseStartTime;
		pauseStartTime = now;

		if (isRecordingMode && recorder != null)
		{
			recorder.pause();
			recorder.takeSnapshot();
			trace(recorder.toString());
		}
	}

	public function resume()
	{
		isPhysicsEnabled = true;
		isGamePaused = false;

		if (pauseStartTime != 0) totalPausedTime += now - pauseStartTime;
		pauseStartTime = 0;

		if (recorder != null) recorder.resume();
	}

	public function destroy()
	{
		TweenMax.killTweensOf(cameraZoomHelper);
		TweenMax.killTweensOf(camera);

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

		remove();
	}
}

typedef ActionFlow = {
	var onComplete:Void->Void;
}