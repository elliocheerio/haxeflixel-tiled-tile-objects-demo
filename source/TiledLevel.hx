package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledTilePropertySet;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.tile.FlxTilemapExt;
import haxe.io.Path;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

/**
 * @author Samuel Batista
 */
class TiledLevel extends TiledMap
{
	// For each "Tile Layer" in the map, you must define a "tileset" property which contains the name of a tile sheet image 
	// used to draw tiles in that layer (without file extension). The image file must be located in the directory specified bellow.
	inline static var c_PATH_LEVEL_TILESHEETS = "assets/";
	
	public var backgroundLayer:FlxGroup = new FlxGroup();

	public var tileCollisions:FlxGroup = new FlxGroup();
	
	public function new(tiledLevel:FlxTiledMapAsset, state:PlayState)
	{
		super(tiledLevel);
		
		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);
		
		var tilesetTiledObjects:Array<Dynamic> = [];

		// Load Tile Maps
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.TILE) continue;
			var tileLayer:TiledTileLayer = cast layer;
			
			var tileSheetName:String = tileLayer.properties.get("tileset");
			
			if (tileSheetName == null)
				throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";
				
			var tileSet:TiledTileSet = null;
			for (ts in tilesets)
			{
				if (ts.name == tileSheetName)
				{
					tileSet = ts;

					if (tilesetTiledObjects[tileSet.firstGID] == null)
					{
						tilesetTiledObjects[tileSet.firstGID] = loadTileSetTileObjects(tileSet);
					}

					break;
				}
			}
			
			if (tileSet == null)
				throw "Tileset '" + tileSheetName + " not found. Did you misspell the 'tilesheet' property in " + tileLayer.name + "' layer?";
				
			var imagePath 		= new Path(tileSet.imageSource);
			var processedPath 	= c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;
			
			// could be a regular FlxTilemap if there are no animated tiles
			var tilemap = new FlxTilemapExt();

			tilemap.ignoreDrawDebug = true;
			
			tilemap.loadMapFromArray(tileLayer.tileArray, width, height, processedPath,
				tileSet.tileWidth, tileSet.tileHeight, OFF, tileSet.firstGID, 1, 1);

			processTileSetTileObjects(tileLayer, tilemap, tilesetTiledObjects[tileSet.firstGID]);

            backgroundLayer.add(tilemap);
		}

		state.tiledTileObjects = tileCollisions;
	}

	private function loadTileSetTileObjects(tileSet:TiledTileSet):Array<Dynamic>
	{
		var tileObjects:Array<Dynamic> = [];

		// get all Tiled Tile objects
		for (i in 0...tileSet.tileProps.length)
		{
			if (tileSet.tileProps[i] != null)
			{
				var tileID = tileSet.tileProps[i].tileID;
				tileObjects[tileID] = tileSet.tileProps[i].tileObjects;
			}
		}

		return tileObjects;
	}
	
	private function processTileSetTileObjects(tiledLayer:TiledTileLayer, tilemap:FlxTilemapExt, tileSetObjects:Array<Dynamic>)
	{
		for (i in 0...tiledLayer.tiles.length)
		{	
			if (tiledLayer.tiles[i] != null)
			{
				// tilesetIDs in TiledTileLayer are indexed from 1?
				var tilesetID:Int = tiledLayer.tiles[i].tilesetID - 1;
				var tile:FlxPoint = tilemap.getTileCoordsByIndex(i, false);

				// add Tiled Tile Objects
				if (tileSetObjects[tilesetID] != null)
				{
					var tileObjects:Array<Dynamic> = tileSetObjects[tilesetID];

					for (j in 0...tileObjects.length)
					{
						var tileCollisionObject:FlxObject = new FlxObject(
							tile.x + tileObjects[j].x,
							tile.y + tileObjects[j].y,
							tileObjects[j].width,
							tileObjects[j].height);
						
						tileCollisionObject.debugBoundingBoxColor = FlxColor.RED;
						tileCollisionObject.immovable = true;

						tileCollisions.add(tileCollisionObject);
					}
				}
			}
		}
	}
}