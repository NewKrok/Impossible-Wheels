package iw.game.ui;

import h2d.Layers;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameUi extends Layers
{
	var mainMenu:Layers;

	var resumeRequest:Void->Void;
	var pauseRequest:Void->Void;

	public function new(resumeRequest:Void->Void, pauseRequest:Void->Void, parent:Layers)
	{
		super(parent);

		this.resumeRequest = resumeRequest;
		this.pauseRequest = pauseRequest;
	}

	function onResumeRequest(_)
	{
		resumeRequest();
	}
}