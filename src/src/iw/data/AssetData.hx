package iw.data;

import h2d.Bitmap;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class AssetData
{
	public static function getBitmap(id:String, parent:Object = null) return switch (id)
	{
		case "finishFlag": new Bitmap(Res.image.game_asset.finish_flag.toTile(), parent);
		case _: null;
	}
}