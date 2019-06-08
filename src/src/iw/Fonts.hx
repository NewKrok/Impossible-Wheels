package iw;

import h2d.Font;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Fonts
{
	public static var DEFAULT_S(default, null):Font;
	public static var DEFAULT_M(default, null):Font;
	public static var DEFAULT_L(default, null):Font;

	public static function init()
	{
		DEFAULT_S  = Res.font.Aachen_Medium_Plain.build(20);
		DEFAULT_M  = Res.font.Aachen_Medium_Plain.build(28);
		DEFAULT_L  = Res.font.Aachen_Medium_Plain.build(35);

		DEFAULT_S.setOffset(0, 1);
		DEFAULT_M.setOffset(0, 1);
		DEFAULT_L.setOffset(0, 1);
	}
}