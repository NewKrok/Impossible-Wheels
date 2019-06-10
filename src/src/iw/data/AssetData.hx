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
	public static function getBitmap(id:String, parent:Object = null)
	{
		var bmp;

		switch (id)
		{
			case "finishFlag":
				bmp = new Bitmap(Res.image.game_asset.finish_flag.toTile(), parent);

			case "table_direction":
				bmp = new Bitmap(Res.image.game_asset.direction_flag.toTile(), parent);
				bmp.tile.dx = bmp.tile.width / 2;
				bmp.tile.dy = bmp.tile.height / 2 - 15;

			case "table_danger":
				bmp = new Bitmap(Res.image.game_asset.danger_flag.toTile(), parent);
				bmp.tile.dx = bmp.tile.width / 2;
				bmp.tile.dy = bmp.tile.height / 2 - 15;

			case "table_warning":
				bmp = new Bitmap(Res.image.game_asset.alert_flag.toTile(), parent);
				bmp.tile.dx = bmp.tile.width / 2;
				bmp.tile.dy = bmp.tile.height / 2 - 15;

			case _: bmp = null;
		}

		return bmp;
	}
}