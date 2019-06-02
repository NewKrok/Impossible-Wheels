package iw.game.ui;

import h2d.Object;
import h2d.Text;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class CoinUi extends Object
{
	public function new(p, collectedCoins:Observable<UInt>, totalCoinCount:UInt)
	{
		super(p);

		var cointText = new Text(Fonts.DEFAULT_M, this);
		cointText.smooth = true;
		cointText.textColor = 0xFFFFFF;
		cointText.textAlign = Align.Left;

		collectedCoins.bind(function(v) {
			cointText.text = v + "/" + totalCoinCount;
		});
	}
}