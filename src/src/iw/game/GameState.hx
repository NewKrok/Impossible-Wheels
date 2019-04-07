package iw.game;

import com.greensock.TweenMax;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import iw.AppModel;
import iw.game.GameModel;
import iw.game.ui.GameUi;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameState extends Base2dState
{
	var appModel:AppModel;

	var gameModel:GameModel;

	var world:World;
	var ui:GameUi;

	public function new(stage:Base2dStage, appModel:AppModel, levelId:UInt)
	{
		this.appModel = appModel;
		gameModel = new GameModel({
			levelId: levelId
		});

		super(stage);
	}

	override function build()
	{
		world = new World(
			stage,
			appModel.getLevelData(gameModel.levelId).levelData,
			false,
			appModel.observables.isEffectEnabled
		);
		world.build().onComplete = init;

		//ui = new GameUi(resumeRequest, pauseRequest, stage);
	}

	function init()
	{
		var startPoint = appModel.getLevelData(gameModel.levelId).levelData.startPoint;
		world.jumpCameraTo(startPoint.x + 300, startPoint.y);
	}

	function reset()
	{
		start();
	}

	function start():Void
	{
		resumeRequest();

		world.resume();
	}

	override public function update(delta:Float)
	{
		world.update(delta);
	}

	function resumeRequest()
	{
		TweenMax.resumeAll(true, true, true);

		world.resume();
	}

	function pauseRequest()
	{
		TweenMax.pauseAll(true, true, true);

		world.pause();
	}

	override public function onFocus()
	{
		resumeRequest();
	}

	override public function onFocusLost()
	{
		pauseRequest();
	}

	override public function dispose()
	{
		world.destroy();

		super.dispose();
	}
}