package
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import jam.Assets;
	import jam.FuzzTransition;
	import jam.Level;
	import jam.MainMenu;
	import jam.Stats;
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.TapGesture;
	import org.gestouch.gestures.TransformGesture;
	import punk.core.Engine;
	import punk.util.Input;
	import punk.util.Key;
	
	public class Main extends Engine
	{
		[Embed(source = "assets/fonts/04B_03__.ttf", fontName = "MAIN_04b03", mimeType = "application/x-font", advancedAntiAliasing = "true", embedAsCFF = "false")]
		static public var MAIN_Text_04b03:Class;
		
		static public var instance:Main = null;
		
		public function get Height():uint
		{
			return 480;
		}
		
		public function get Width():uint
		{
			return 640;
		}
		
		public var config:Object = null;
		
		public var file_reference_list:FileReferenceList = null;
		
		public var level:Object = null;

		public var paused:Boolean = false;

		public var pauseNextFrame:Boolean = false;
		
		public var level_select:Object = null;
		
		public var levels:Object = null;
		
		public var main_menu:MainMenu = null;
		
		public var LEVELS:Object = null;
		
		public var LEVELS_BEST:Object = null;
		
		public var MC_LEVEL:MovieClip = null;

		public var MC_MEMORY_WATCH:MovieClip = null;
		
		public var TEXT_FORMAT:TextFormat = null;
		
		public function Main()
		{
			Main.instance = this;
			
			File.applicationStorageDirectory.resolvePath ("assets/levels/").createDirectory ();
			
			super(320, 240, 60, 2, MainMenu);
		}
		
		override public function init():void
		{
			Input.define("right", Key.RIGHT);
			Input.define("left", Key.LEFT);
			Input.define("up", Key.UP);
			Input.define("down", Key.DOWN);
			Input.define("jump", Key.X, Key.UP, Key.S);
			Input.define("grapple", Key.Z, Key.A);
			Input.define("skip", Key.ENTER);
			Input.define("pause", Key.P);
			Input.define("unpause", Key.O);
			Input.define("frame", Key.L);
			
			Main.instance.stage.addEventListener(Event.ENTER_FRAME, this.HandleEvent);
			Main.instance.stage.addEventListener(Event.RESIZE, this.HandleEvent);
			Main.instance.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.HandleEvent);
			Main.instance.stage.addEventListener(KeyboardEvent.KEY_UP, this.HandleEvent);
			
			Main.instance.config = Main.instance.Config(null);
			Main.instance.file_reference_list = new FileReferenceList ();
			Main.instance.level = new Object();
			Main.instance.level_select = new Object();
			Main.instance.level.repeat = false;
			Main.instance.level.select = 0;
			Main.instance.level.tas = 0;
			Main.instance.level.tassing = false;
			Main.instance.level.text = null;
			Main.instance.level.time = 0;
			Main.instance.level_select.state = false;
			Main.instance.levels = new Object ();
			Main.instance.main_menu = null;
			Main.instance.stage.displayState = ((Main.instance.config.OPTIONS.FULLSCREEN == false) ? StageDisplayState.NORMAL : StageDisplayState.FULL_SCREEN_INTERACTIVE);
			Main.instance.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			Main.instance.LEVELS = new Object ();
			
			Main.instance.LEVELS_BEST = new Object ();
			
			Main.instance.MC_LEVEL = new MovieClip ();
			
			Main.instance.MC_LEVEL.MC_LIST = new MovieClip ();
			Main.instance.MC_LEVEL.MC_MASK = new MovieClip ();
			
			Main.instance.MC_LEVEL.gesture_transform = Main.instance.GestureTransform (Main.instance.MC_LEVEL, this.HandleEvent);
			
			Main.instance.MC_LEVEL.graphics.beginFill (0x000000, 0.0);
			Main.instance.MC_LEVEL.graphics.drawRect (0.0, 0.0, 400.0, 250.0);
			Main.instance.MC_LEVEL.graphics.endFill ();
			
			Main.instance.MC_LEVEL.MC_MASK.graphics.beginFill (0x000000, 0.5);
			Main.instance.MC_LEVEL.MC_MASK.graphics.drawRect (0.0, 0.0, 400.0, 250.0);
			Main.instance.MC_LEVEL.MC_MASK.graphics.endFill ();
			
			Main.instance.MC_LEVEL.addChild (Main.instance.MC_LEVEL.MC_LIST);
			Main.instance.MC_LEVEL.addChild (Main.instance.MC_LEVEL.MC_MASK);
			
			Main.instance.MC_LEVEL.x = ((this.Width - Main.instance.MC_LEVEL.width) * 0.5);
			Main.instance.MC_LEVEL.y = 150.0;
			
			Main.instance.MC_LEVEL.MC_LIST.mask = Main.instance.MC_LEVEL.MC_MASK;
			
			Main.instance.MC_LEVEL.visible = false;
			
			Main.instance.TEXT_FORMAT = new TextFormat ("MAIN_04b03", 24, 16777215, null, null, null, null, null, TextFormatAlign.CENTER, null, null, null, null);
			
			Main.instance.addChild (Main.instance.MC_LEVEL);
			
			Main.instance.MC_MEMORY_WATCH = new MovieClip();
			Main.instance.MC_MEMORY_WATCH.MC_LIST = new MovieClip();
			Main.instance.MC_MEMORY_WATCH.MC_MASK = new MovieClip();
			Main.instance.MC_MEMORY_WATCH.TEXT_FIELD = new TextField();
			Main.instance.MC_MEMORY_WATCH.TEXT_FORMAT = new TextFormat("04b03",12,16777215,null,null,null,null,null,"left",null,null,null,null);
			Main.instance.MC_MEMORY_WATCH.TEXT_FIELD.autoSize = "left";
			Main.instance.MC_MEMORY_WATCH.TEXT_FIELD.embedFonts = true;
			Main.instance.MC_MEMORY_WATCH.TEXT_FIELD.selectable = false;
			Main.instance.MC_MEMORY_WATCH.TEXT_FIELD.text = "Memory Watch";
			Main.instance.MC_MEMORY_WATCH.TEXT_FIELD.textColor = 16777215;
			Main.instance.MC_MEMORY_WATCH.TEXT_FIELD.setTextFormat(Main.instance.MC_MEMORY_WATCH.TEXT_FORMAT);
			Main.instance.MC_MEMORY_WATCH.visible = true;
			Main.instance.MC_MEMORY_WATCH.MC_LIST.mask = Main.instance.MC_MEMORY_WATCH.MC_MASK;
			Main.instance.MC_MEMORY_WATCH.MC_LIST.TEXT_FIELD = new TextField();
			Main.instance.MC_MEMORY_WATCH.MC_LIST.TEXT_FORMAT = new TextFormat("04b03",12,16777215,null,null,null,null,null,"left",null,null,null,null);
			Main.instance.MC_MEMORY_WATCH.MC_LIST.TEXT_FIELD.autoSize = "left";
			Main.instance.MC_MEMORY_WATCH.MC_LIST.TEXT_FIELD.embedFonts = true;
			Main.instance.MC_MEMORY_WATCH.MC_LIST.TEXT_FIELD.selectable = false;
			Main.instance.MC_MEMORY_WATCH.MC_LIST.TEXT_FIELD.x = 0;
			Main.instance.MC_MEMORY_WATCH.MC_LIST.TEXT_FIELD.y = Main.instance.MC_MEMORY_WATCH.TEXT_FIELD.height;
			Main.instance.MC_MEMORY_WATCH.graphics.beginFill(0,0.5);
			Main.instance.MC_MEMORY_WATCH.graphics.drawRect(0,0,Main.instance.Height * 0.5,Main.instance.Width * 0.22 * 0.75);
			Main.instance.MC_MEMORY_WATCH.graphics.endFill();
			Main.instance.MC_MEMORY_WATCH.x = Main.instance.Width - Main.instance.MC_MEMORY_WATCH.width;
			Main.instance.MC_MEMORY_WATCH.y = 0;
			Main.instance.MC_MEMORY_WATCH.MC_MASK.graphics.beginFill(0,0);
			Main.instance.MC_MEMORY_WATCH.MC_MASK.graphics.drawRect(0,0,Main.instance.Height * 0.5,Main.instance.Width * 0.22 * 0.75);
			Main.instance.MC_MEMORY_WATCH.MC_MASK.graphics.endFill();
			Main.instance.MC_MEMORY_WATCH.addChild(Main.instance.MC_MEMORY_WATCH.MC_LIST);
			Main.instance.MC_MEMORY_WATCH.addChild(Main.instance.MC_MEMORY_WATCH.MC_MASK);
			Main.instance.MC_MEMORY_WATCH.addChild(Main.instance.MC_MEMORY_WATCH.TEXT_FIELD);
			Main.instance.MC_MEMORY_WATCH.MC_LIST.addChild(Main.instance.MC_MEMORY_WATCH.MC_LIST.TEXT_FIELD);
			Main.instance.stage.addChild(Main.instance.MC_MEMORY_WATCH);

			Main.instance.file_reference_list.addEventListener (Event.SELECT, this.HandleEvent, false, 0, false);
			
			Assets.timer = ((Main.instance.config.OPTIONS.GAME_TIMER == null) ? Assets.timer : Main.instance.config.OPTIONS.GAME_TIMER);
			Assets.particles = ((Main.instance.config.OPTIONS.PARTICLES == null) ? Assets.particles : Main.instance.config.OPTIONS.PARTICLES);
			
			FP.musicVolume = ((Main.instance.config.OPTIONS.MUSIC == null) ? FP.musicVolume : Main.instance.config.OPTIONS.MUSIC);
			FP.soundVolume = ((Main.instance.config.OPTIONS.SOUNDS == null) ? FP.soundVolume : Main.instance.config.OPTIONS.SOUNDS);
			
			Main.instance.LoadLevelsBest ();
			
			Main.instance.LoadLevels ();
			
			return;
		}
		
		public function Config(config:Object = null):Object
		{
			var file:File = File.applicationStorageDirectory.resolvePath("CONFIG.txt");
			
			var file_x:File = File.applicationDirectory.resolvePath("CONFIG.txt");
			
			var file_stream:FileStream = new FileStream();
			
			var object:Object = null;
			
			if (file.exists == false)
			{
				file_stream.open(file_x, FileMode.READ);
				object = file_stream.readUTFBytes(file_stream.bytesAvailable);
				file_stream.close();
				
				file_stream.open(new File(file.nativePath), FileMode.WRITE);
				file_stream.writeUTFBytes(String(object));
				file_stream.close();
			}
			
			if (config == null)
			{
			}
			else
			{
				file_stream.open(new File(file.nativePath), FileMode.WRITE);
				file_stream.writeUTFBytes(JSON.stringify(config, null, "\t"));
				file_stream.close();
			}
			
			file_stream.open(file, FileMode.READ);
			object = JSON.parse(file_stream.readUTFBytes(file_stream.bytesAvailable), null);
			file_stream.close();
			
			return object;
		}

		public function Console(param1:String) : Main
		{
			Main.instance.MC_MEMORY_WATCH.MC_LIST.TEXT_FIELD.text = param1;
			Main.instance.MC_MEMORY_WATCH.MC_LIST.TEXT_FIELD.textColor = 16777215;
			Main.instance.MC_MEMORY_WATCH.MC_LIST.TEXT_FIELD.setTextFormat(Main.instance.MC_MEMORY_WATCH.MC_LIST.TEXT_FORMAT);
			return this;
		}
		
		public function GetBestTime(level:String, mode:String):Object
		{
			var best_time:int = 0;
			
			try
			{
				best_time = ((this.config["LEVEL"][mode][level].BEST_TIME == null) ? null : this.config["LEVEL"][mode][level].BEST_TIME);
			}
			catch (error:Error)
			{
				best_time = null;
			}
			
			return best_time;
		}
		
		public function HandleEvent(event:Event):Main
		{
			switch (event.currentTarget)
			{
				case this.file_reference_list :
				{
					switch (event.type)
					{
						case Event.SELECT :
						{
							var file_reference:FileReference = null;
							
							for each (file_reference in this.file_reference_list.fileList)
							{
								file_reference.addEventListener (Event.COMPLETE, this.HandleEvent, false, 0, false);
								
								file_reference.load ();
							}
							
							break;
						}
						default :
						{
							break;
						}
					}
					
					break;
				}
				case this.stage:
				{
					switch (event.type)
					{
						case Event.ENTER_FRAME:
						{
							break;
						}
						case Event.RESIZE:
						{
							this.Resize(this.stage.stageWidth, this.stage.stageHeight);
							
							break;
						}
						case KeyboardEvent.KEY_DOWN:
						{
							switch ((event as KeyboardEvent).keyCode)
							{
								case Keyboard.ESCAPE:
								{
									event.preventDefault();
									event.stopImmediatePropagation();
									
									break;
								}
								default:
								{
									break;
								}
							}
							
							break;
						}
						case KeyboardEvent.KEY_UP:
						{
							switch ((event as KeyboardEvent).keyCode)
							{
								case Keyboard.BACKSPACE:
								{
									if (Level.instance == null)
									{
									}
									else
									{
										TAS.Instance.Initialize();
										
										Main.instance.config.OPTIONS.USE_TAS = false;
										
										Main.instance.level.tas = 0;
										Main.instance.level.tassing = false;
										
										Level.instance.add(new FuzzTransition(FuzzTransition.GOTO_PREVIOUS));
									}
									
									break;
								}
								case Keyboard.ESCAPE:
								{
									TAS.Instance.Initialize();
									
									Main.instance.config.OPTIONS.USE_TAS = false;
									
									Main.instance.level.tas = 0;
									Main.instance.level.tassing = false;
									
									FP.world.add(new FuzzTransition(FuzzTransition.MENU, MainMenu));
									
									break;
								}
								case Keyboard.R:
								{
									if (Level.instance == null)
									{
									}
									else
									{
										TAS.Instance.Initialize();
										
										Main.instance.config.OPTIONS.USE_TAS = false;
										
										Main.instance.level.tas = 0;
										Main.instance.level.tassing = false;
										
										Level.instance.add(new FuzzTransition(FuzzTransition.RESTART));
									}
									
									break;
								}
								case Keyboard.T:
								{
									if (Input.checkKey(Key.CONTROL) && Input.checkKey(Key.SHIFT))
									{
										Main.instance.config.OPTIONS.USE_TAS = true;
										
										Main.instance.level.tas = Assets.TOTAL_LEVELS[Stats.saveData.mode];
										Main.instance.level.tassing = false;
										
										Level.instance.add(new FuzzTransition(FuzzTransition.NEW));
										
										Stats.resetStats();
									}
									else
									{
										Main.instance.config.OPTIONS.USE_TAS = false;
										
										Main.instance.level.tas = 1;
										Main.instance.level.tassing = false;
										
										Level.instance.add(new FuzzTransition(FuzzTransition.RESTART));
									}
									
									break;
								}
								case Keyboard.TAB:
								{
									if (Level.instance == null)
									{
									}
									else
									{
										TAS.Instance.Initialize();
										
										Main.instance.config.OPTIONS.USE_TAS = false;
										
										Main.instance.level.tas = 0;
										Main.instance.level.tassing = false;
										
										Level.instance.add(new FuzzTransition(FuzzTransition.GOTO_NEXT));
									}
									
									break;
								}
								default:
								{
									break;
								}
							}
							
							break;
						}
						default:
						{
							break;
						}
					}
					
					break;
				}
				case Main.instance.MC_LEVEL.gesture_transform :
				{
					switch (event.type)
					{
						case GestureEvent.GESTURE_CHANGED :
						{
							Main.instance.Transform
							(
								event.currentTarget.target.MC_LIST,
								event.currentTarget.offsetX,
								event.currentTarget.offsetY,
								false,
								event.currentTarget.location,
								0.0,
								event.currentTarget.scale,
								1.0,
								1.0,
								0.0, 0.0,
								-Number.MAX_VALUE, Number.MAX_VALUE,
								this
							);
							
							//Main.Instance.Transform (event.currentTarget.target, event.currentTarget.offsetX, event.currentTarget.offsetY, 0.0, 0.0, event.currentTarget.target.y_max, event.currentTarget.target.y_min, this);
							
							break;
						}
						default :
						{
							break;
						}
					}
					
					break;
				}
				default:
				{
					var level:Object = new Object ();
					
					if (event.currentTarget is FileReference)
					{
						var file_reference:FileReference = (event.currentTarget as FileReference);
						
						var file:File = null;
						
						var file_stream:FileStream = null;
						
						var xml:XML = null;
						
						file_reference.data.position = 0;
						
						xml = new XML (file_reference.data.readUTFBytes (file_reference.data.length));
						
						file_reference.removeEventListener (Event.COMPLETE, this.HandleEvent, false);
						
						level.mode = new String (xml.@mode).toUpperCase ();
						level.name = new String (xml.@name);
						level.x = Assets.PREFIXES.indexOf (level.mode, 0);
						
						file = new File (File.applicationStorageDirectory.resolvePath ("assets/levels/").nativePath.concat ("/").concat (level.name).concat (".bin"));
						
						file_stream = new FileStream ();
						
						file_stream.open (file, FileMode.WRITE);
						{
							file_reference.data.position = 0;
							
							file_stream.writeBytes (file_reference.data, 0, 0);
						}
						file_stream.close ();
						
						Main.instance.SaveLevel (file_reference.data);
					}
					else if (event.currentTarget is TapGesture)
					{
						switch (event.type)
						{
							case GestureEvent.GESTURE_RECOGNIZED :
							{
								level = event.currentTarget.target;
								
								Main.instance.level.select = (Assets.TOTAL_LEVELS [1] + 1);
								
								Stats.resetStats();
								Stats.saveData.mode = 1;
								
								Main.instance.level_select.level = level;
								Main.instance.level_select.state = true;
								
								Main.instance.MC_LEVEL.visible = false;
								
								Assets [Assets.PREFIXES[Stats.saveData.mode] + Main.instance.level.select] = level.data;
								
								Main.instance.main_menu.newGameSelect();
								
								break;
							}
							default :
							{
								break;
							}
						}
					}
					else if (event.currentTarget is MovieClip)
					{
						if (event.currentTarget.ID == "LEVEL")
						{
							level = event.currentTarget;
							
							switch (event.type)
							{
								case MouseEvent.MOUSE_OUT :
								case MouseEvent.RELEASE_OUTSIDE :
								{
									level.TEXT_FIELD.setTextFormat (new TextFormat ("MAIN_04b03", 24, 16777215, null, null, null, null, null, TextFormatAlign.CENTER, null, null, null, null));
									
									level.TEXT_FIELD.textColor = 0xFFFFFF;
									
									level.alpha = 0.5;
									
									break;
								}
								case MouseEvent.MOUSE_OVER :
								{
									level.TEXT_FIELD.setTextFormat (new TextFormat ("MAIN_04b03", 32, 16777215, null, null, null, null, null, TextFormatAlign.CENTER, null, null, null, null));
									
									level.TEXT_FIELD.textColor = 0xFFFFFF;
									
									level.alpha = 1.0;
									
									break;
								}
								default :
								{
									break;
								}
							}
						}
					}
					
					break;
				}
			}
			
			return this;
		}
		
		public function LoadLevels () : Main
		{
			var byte_array:ByteArray = null;
			
			var file:File = null;
			
			var files:File = File.applicationStorageDirectory.resolvePath ("assets/levels/");
			
			var file_stream:FileStream = new FileStream ();
			
			for each (file in files.getDirectoryListing ())
			{
				byte_array = new ByteArray ();
				
				file_stream.open (file, FileMode.READ);
				{
					file_stream.readBytes (byte_array, 0, 0);
				}
				file_stream.close ();
				
				Main.instance.SaveLevel (byte_array);
			}
			
			return this;
		}
		
		public function SaveLevel (byte_array:ByteArray) : Main
		{
			var level:MovieClip = new MovieClip ();
			
			var xml:XML = new XML (byte_array.readUTFBytes (byte_array.length));
			
			level.mode = new String (xml.@mode).toUpperCase ();
			level.name = new String (xml.@name);
			level.data = byte_array;
			
			if (Main.instance.LEVELS [level.name] == null)
			{
				level.ID = "LEVEL";
				
				level.alpha = 0.5;
				
				level.graphics.beginFill (0x000000, 0.0);
				level.graphics.drawRect (0.0, 0.0, 400.0, 40.0);
				level.graphics.endFill ();
				
				level.TEXT_FIELD = new TextField ();
				level.TEXT_FIELD.autoSize = TextFieldAutoSize.CENTER;
				level.TEXT_FIELD.embedFonts = true;
				level.TEXT_FIELD.selectable = false;
				level.TEXT_FIELD.text = level.name;
				
				level.TEXT_FIELD.setTextFormat (Main.instance.TEXT_FORMAT);
				level.TEXT_FIELD.textColor = 0xFFFFFF;
				
				level.TEXT_FIELD.x = ((level.width - level.TEXT_FIELD.textWidth) * 0.5);
				level.TEXT_FIELD.y = ((level.height - level.TEXT_FIELD.textHeight) * 0.5);
				
				level.addChild (level.TEXT_FIELD);
				
				level.gesture_tap = Main.instance.GestureTap (level, this.HandleEvent);
				level.x = ((400 - level.width) * 0.5);
				level.y = Main.instance.MC_LEVEL.MC_LIST.height;
				
				level.addEventListener (MouseEvent.MOUSE_OUT, this.HandleEvent, false, 0, false);
				level.addEventListener (MouseEvent.MOUSE_OVER, this.HandleEvent, false, 0, false);
				level.addEventListener (MouseEvent.RELEASE_OUTSIDE, this.HandleEvent, false, 0, false);
				
				Main.instance.LEVELS [level.name] = level;
				
				if (Main.instance.LEVELS_BEST [level.name] == null)
				{
					Main.instance.LEVELS_BEST [level.name] = -1;
				}
				else
				{
					Main.instance.LEVELS_BEST [level.name] = Main.instance.LEVELS_BEST [level.name];
				}
				
				Main.instance.MC_LEVEL.MC_LIST.addChild (level);
			}
			
			return this;
		}
		
		public function Resize(width:Number, height:Number):Main
		{
			this.scaleX = this.scaleY = Math.min((height / this.Height), (width / this.Width));
			
			this.x = ((this.stage.stageWidth - (this.Width * this.scaleX)) * 0.5);
			this.y = ((this.stage.stageHeight - (this.Height * this.scaleY)) * 0.5);
			
			return this;
		}
		
		public function GestureTap (display_object:DisplayObject, handle_event:Function) : TapGesture
		{
			var gesture_tap:TapGesture = new TapGesture (display_object);
			
			gesture_tap.addEventListener (GestureEvent.GESTURE_RECOGNIZED, handle_event, false, 0, false);
			
			return gesture_tap;
		}
		
		public function GestureTransform (display_object:DisplayObject, handle_event:Function) : TransformGesture
		{
			var gesture_transform:TransformGesture = new TransformGesture (display_object);
			
			gesture_transform.addEventListener (GestureEvent.GESTURE_BEGAN, handle_event, false, 0, false);
			gesture_transform.addEventListener (GestureEvent.GESTURE_CHANGED, handle_event, false, 0, false);
			gesture_transform.addEventListener (GestureEvent.GESTURE_ENDED, handle_event, false, 0, false);
			
			return gesture_transform;
		}
		
		public function Transform (display_object:DisplayObject, dX:Number, dY:Number, flag:Boolean, location:Point, rotation:Number, scale:Number, scaleX:Number, scaleY:Number, maxX:Number, minX:Number, maxY:Number, minY:Number, _this:Object = null) : Main
		{
			var matrix:Matrix = display_object.transform.matrix;
			
			var transformPoint:Point = null;
			
			{
				if (_this == null)
				{
					matrix.translate ((dX * (1.0 / display_object.parent.scaleX)), (dY * (1.0 / display_object.parent.scaleY)));
				}
				else
				{
					matrix.translate ((dX * (1.0 / display_object.parent.scaleX) * ((_this.rotation == 0.0) ? 1.0 : -1.0)), (dY * (1.0 / display_object.parent.scaleY) * ((_this.rotation == 0.0) ? 1.0 : -1.0)));
				}
				
				matrix.tx = Math.max (maxX, Math.min (minX, matrix.tx));
				matrix.ty = Math.max (maxY, Math.min (minY, matrix.ty));
				
				display_object.transform.matrix = matrix;
			}
			
			if (flag == false)
			{
			}
			else
			{
				{
					transformPoint = matrix.transformPoint (display_object.globalToLocal (location));
					
					matrix.translate (-transformPoint.x, -transformPoint.y);
					matrix.rotate (rotation);
					matrix.scale (scale, scale);
					matrix.translate (transformPoint.x, transformPoint.y);
					
					display_object.transform.matrix = matrix;
				}
			}
			
			return this;
		}
		
		public function LoadLevelsBest () : Main
		{
			var byte_array:ByteArray = new ByteArray ();
			
			var file:File = new File (File.applicationStorageDirectory.resolvePath ("LEVELS_BEST.bin").nativePath);
			
			var file_stream:FileStream = new FileStream ();
			
			if (file.exists == false)
			{
			}
			else
			{
				file_stream.open (file, FileMode.READ);
				{
					file_stream.readBytes (byte_array, 0, 0);
					
					byte_array.position = 0;
					
					Main.instance.LEVELS_BEST = byte_array.readObject ();
				}
				file_stream.close ();
			}
			
			return this;
		}
		
		public function SaveLevelsBest () : Main
		{
			var byte_array:ByteArray = new ByteArray ();
			
			var file:File = new File (File.applicationStorageDirectory.resolvePath ("LEVELS_BEST.bin").nativePath);
			
			var file_stream:FileStream = new FileStream ();
			
			file_stream.open (file, FileMode.WRITE);
			{
				byte_array.writeObject (Main.instance.LEVELS_BEST);
				
				byte_array.position = 0;
				
				file_stream.writeBytes (byte_array, 0, 0);
			}
			file_stream.close ();
			
			return this;
		}
	}
}
