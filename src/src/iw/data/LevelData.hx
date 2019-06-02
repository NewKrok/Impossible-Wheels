package iw.data;

import hpp.util.GeomUtil.SimplePoint;

/**
 * ...
 * @author Krisztian Somoracz
 */
typedef LevelData =
{
	var worldId(default, never):UInt;
	var levelId(default, never):UInt;

	@:optional var opponentsScore(default, never):UInt;

	@:skipCheck var cameraBounds(default, never):{ x:Float, y:Float, width:Float, height:Float };
	@:skipCheck var startPoint(default, never):SimplePoint;
	@:skipCheck var finishPoint(default, never):SimplePoint;
	@:skipCheck var polygonGroundData(default, never):Array<Array<Array<PolygonBackgroundData>>>;
	@:skipCheck var polygonBackgroundData(default, never):Array<Array<Array<PolygonBackgroundData>>>;
	@:skipCheck var collectableItems(default, never):Array<SimplePoint>;
	@:skipCheck @:optional var replay(default, never):String;
	@:skipCheck @:optional var bridgePoints(default, never):Array<BridgeData>;
	@:skipCheck @:optional var libraryElements(default, never):Array<LibraryElement>;

	// Should be handled in the level editor... Maybe once...
	@:skipCheck var starValues:Array<UInt>;
	@:skipCheck @:optional var staticElementData:Array<StaticElement>;
}

typedef PolygonBackgroundData =
{
	var polygon(default, never):Array<SimplePoint>;
	var terrainTextureId(default, never):String;
	var usedWorldBlocks(default, never):Array<SimplePoint>;
}

typedef BridgeData =
{
	var bridgeAX(default, never):Float;
	var bridgeAY(default, never):Float;
	var bridgeBX(default, never):Float;
	var bridgeBY(default, never):Float;
}

typedef StaticElement =
{
	var position(default, never):SimplePoint;
	var pivotX(default, never):Float;
	var pivotY(default, never):Float;
	var scaleX(default, never):Float;
	var scaleY(default, never):Float;
	var rotation(default, never):Float;
	var elementId(default, never):String;
}

typedef LibraryElement =
{
	var x(default, never):Float;
	var y(default, never):Float;
	var className(default, never):String;
	var scale(default, never):Float;
}