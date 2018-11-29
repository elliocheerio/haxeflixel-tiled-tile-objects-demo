package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flash.system.System;
import flash.Lib;

class PlayState extends FlxState
{
	public var player:FlxSprite;

	public var tiledTileObjects:FlxGroup = new FlxGroup();

	override public function create():Void
	{
		super.create();

		var level = new TiledLevel("assets/level.tmx", this);

		player = new FlxSprite("assets/player.png");
		player.x = 152;
		player.y = 152;

		add(level.backgroundLayer);

		add(tiledTileObjects);

		add(player);

		FlxG.camera.follow(player, LOCKON);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		input();

		FlxG.collide(player, tiledTileObjects);
	}

	private function input():Void
	{
		var velocity:Int = 50;

		player.velocity.x = 0;
		player.velocity.y = 0;

		if (FlxG.keys.anyPressed([LEFT, A]))
		{
			player.velocity.x -= velocity;
		}
		if (FlxG.keys.anyPressed([RIGHT, D]))
		{
			player.velocity.x += velocity;
		}
		if (FlxG.keys.anyPressed([W, UP]))
		{
			player.velocity.y -= velocity;
		}
		if (FlxG.keys.anyPressed([S, DOWN]))
		{
			player.velocity.y += velocity;
		}

		// quit
		if (FlxG.keys.anyPressed([ESCAPE]))
		{
			#if !flash
			System.exit(0);
			#else
			Lib.fscommand("quit");
			#end
		}
	}
}
