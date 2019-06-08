package iw.game.ui;

import com.greensock.TweenMax;
import h2d.Object;
import hpp.heaps.HppG;
import hpp.util.Language;
import iw.game.ui.StartCounterEntry;

/**
 * ...
 * @author Krisztian Somoracz
 */
class StartCounterUi extends Object
{
	var entries:Array<StartCounterEntry> = [];

	public function new(p)
	{
		super(p);

		addEntry(Language.get("ready"));
		addEntry(Language.get("set"));
		addEntry(Language.get("go"));
	}

	function addEntry(label:String)
	{
		var e = new StartCounterEntry(this, label);
		e.alpha = 0;
		entries.push(e);
	}

	public function start()
	{
		for (i in 0...entries.length)
		{
			var e = entries[i];
			e.x = HppG.stage2d.width;
			e.y = HppG.stage2d.height / 2 - e.getSize().height / 2;
			e.alpha = 0;

			TweenMax.to(e, .2, {
				x: HppG.stage2d.width - e.getSize().width,
				alpha: 1,
				onUpdate: function() { e.x = e.x; },
				delay: i * 1,
				onComplete: function()
				{
					if (i < 2) SoundManager.playCounterSound();
					else SoundManager.playStartGameSound();

					TweenMax.to(e, .5, {
						y: e.y + 100,
						alpha: 0,
						onUpdate: function() { e.y = e.y; },
						delay: .8
					});
				}
			});
		}
	}

	public function stop()
	{
		for (i in 0...entries.length)
		{
			var e = entries[i];
			e.x = HppG.stage2d.width;
			e.y = HppG.stage2d.height / 2 - e.getSize().height / 2;
			e.alpha = 0;

			TweenMax.killTweensOf(e);
		}
	}
}