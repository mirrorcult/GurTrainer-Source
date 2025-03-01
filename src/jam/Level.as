package jam
{
	import flash.system.System;
	import flash.utils.ByteArray;
	import punk.Backdrop;
	import punk.Text;
	import punk.core.Alarm;
	import punk.core.Entity;
	import punk.core.World;
	import punk.util.Input;
	
	public class Level extends World
	{
		public static const ImgBG:Class = Library.Preloader_ImgBG;
		
		public static var instance:Level = null;
		
		private var bg:Backdrop;
		
		public var shake:Boolean = false;
		
		private var countTime:Boolean = true;
		
		public var width:uint;
		
		public var levelText:Text;
		
		public var time:uint;
		
		public var shakeAmount:uint;
		
		private var xml:XML;
		
		private var timer:Text;
		
		public var player:Player;
		
		public var levelNum:uint;
		
		public var height:uint;
		
		public var particles:Vector.<Particle>;
		
		private var alarmShake:Alarm;
		
		private var alarmRestart:Alarm;
		
		public function Level(num:uint)
		{
			this.alarmShake = new Alarm(1, this.onAlarmShake, Alarm.PERSIST);
			this.alarmRestart = new Alarm(40, this.onAlarmRestart, Alarm.PERSIST);
			super();
			this.particles = new Vector.<Particle>();
			this.levelNum = num;
			this.getXML();
			addAlarm(this.alarmRestart, false);
			addAlarm(this.alarmShake, false);
			if (Main.instance.config.OPTIONS.USE_TAS == false)
			{
			}
			else
			{
				Main.instance.level.tas = Assets.TOTAL_LEVELS[Stats.saveData.mode];
				Main.instance.level.tassing = false;
			}
		}
		
		public function die():void
		{
			if (this.player == null)
			{
				return;
			}
			Assets.playGoodJob();
			remove(this.player);
			this.player = null;
			Stats.saveData.addDeath();
			Stats.saveData.addTime((FP.world as Level).time);
			this.time = 0;
			this.countTime = false;
			this.alarmRestart.start();
		}
		
		override public function update():void
		{
			if(this.player)
		 	{
				 var _loc1_:String = null;
				_loc1_ = new String();
				_loc1_ = _loc1_ + ("Frame \t\t\t\t: " + this.time);
				_loc1_ = _loc1_ + "\n";
				_loc1_ = _loc1_ + ("Player X Position\t: " + this.player.x);
				_loc1_ = _loc1_ + "\n";
				_loc1_ = _loc1_ + ("Player Y Position\t: " + this.player.y);
				_loc1_ = _loc1_ + "\n";
				_loc1_ = _loc1_ + ("Player X Speed\t: " + this.player.hSpeed);
				_loc1_ = _loc1_ + "\n";
				_loc1_ = _loc1_ + ("Player Y Speed\t: " + this.player.vSpeed);
				_loc1_ = _loc1_ + "\n";
				if (this.player.grapple)
				{
					_loc1_ = _loc1_ + ("Grapple Momentum\t: " + this.player.grapple.momentum);
					_loc1_ = _loc1_ + "\n";
					_loc1_ = _loc1_ + ("Grapple Direction\t: " + this.player.grapple.direction);
					_loc1_ = _loc1_ + "\n";
				}
				Main.instance.Console(_loc1_);
			}
			if (this.countTime)
			{
				this.time++;
			}
			this.bg.x = this.bg.x - 0.25;
			this.bg.y = this.bg.y - 0.25;
			this.levelText.x = 20 + FP.camera.x;
			this.levelText.y = 20 + FP.camera.y;
			if (Assets.timer)
			{
				this.timer.text = Stats.saveData.getTimePlus(this.time);
				this.timer.x = 20 + FP.camera.x;
				this.timer.y = 60 + FP.camera.y;
			}

			if (Main.instance.config.OPTIONS.USE_TAS == false)
			{
			}
			else
			{
				if (Main.instance.level.tas == 0)
				{
				}
				else
				{
					if (Main.instance.level.tassing == false)
					{
						Main.instance.level.tas = int(Math.max(0.0, --Main.instance.level.tas));
						
						Main.instance.level.tassing = true;
						
						TAS.Instance.Open(Main.instance.level.text.replace("TAS ", ""), Assets.PREFIXES[Stats.saveData.mode]);
						
						if (TAS.Instance.read == null)
						{
							Main.instance.config.OPTIONS.USE_TAS = false;
							
							Main.instance.level.tas = 0;
							Main.instance.level.tassing = false;
							
							Level.instance.add(new FuzzTransition(FuzzTransition.RESTART));
						}
					}
				}
			}
			
			return;
		}
		
		public function restart():void
		{
			this.clearParticles();
			removeAll();
			System.gc();
			this.build();
		}
		
		override public function init():void
		{
			this.build();
		}
		
		private function onAlarmRestart():void
		{
			add(new FuzzTransition(FuzzTransition.RESTART));
		}
		
		public function createParticles(amount:uint, x:uint, y:uint, posRand:uint, color:uint, size:uint, sizeRand:uint, speed:Number, speedRand:Number, direction:Number, dirRand:Number, life:uint, lifeRand:uint, delay:uint = 0):void
		{
			var p:Particle = null;
			if (!Assets.particles)
			{
				return;
			}
			for (var i:int = 0; i < amount; i++)
			{
				if (this.particles.length == 0)
				{
					p = new Particle();
				}
				else
				{
					p = this.particles.pop();
				}
				p.setDraw(x - posRand + Math.random() * posRand * 2, y - posRand + Math.random() * posRand * 2, color, size - sizeRand + Math.random() * sizeRand * 2, speed - speedRand + Math.random() * speedRand * 2, direction - dirRand + Math.random() * dirRand * 2, life - lifeRand + Math.random() * lifeRand * 2, delay);
				add(p);
			}
		}
		
		public function win():void
		{
			Main.instance.level.time = this.time;
			
			if (this.player == null)
			{
				return;
			}
			
			TAS.Instance.Save(Level.instance.levelText.text.replace("TAS ", ""), Assets.PREFIXES[Stats.saveData.mode]);
			
			remove(this.player);
			this.player = null;
			Stats.saveData.addTime(this.time);
			FP.play(Assets.SndWin);
			trace ("A");
			if (Main.instance.level.repeat == false)
			{
				trace ("b");
				if (this.levelNum < Assets.TOTAL_LEVELS[Stats.saveData.mode])
				{
					trace ("c");
					if (this.levelNum == 1 && Stats.saveData.mode == 0)
					{
						trace ("d");
						FP.play(Assets.VcGiveUp10, Assets.VCVOL);
					}
					else
					{
						trace ("e");
						Assets.playGiveUp();
					}
					if (Stats.saveData.mode == 0 && this.levelNum % 10 == 0 || Stats.saveData.mode == 1 && this.levelNum == 5)
					{
						trace ("f");
						add(new FuzzTransition(FuzzTransition.MENU, SubmitMenu));
					}
					else
					{
						trace ("g");
						if (Main.instance.config.OPTIONS.SHOW_IL_TIME == false)
						{
							trace ("h");
							if (Main.instance.config.OPTIONS.USE_TAS == false)
							{
								trace ("i");
								if (Main.instance.level.tassing == false)
								{
									trace ("j");
									if (Main.instance.level_select.state == false)
									{
										trace ("k");
										add(new FuzzTransition(FuzzTransition.GOTO_NEXT));
									}
								}
								else
								{
									trace ("l");
									if (Main.instance.level_select.state == false)
									{
										trace ("m");
										add(new FuzzTransition(FuzzTransition.MENU, SubmitMenu));
									}
								}
							}
							else
							{
								trace ("n");
								if (Main.instance.level_select.state == false)
								{
									trace ("o");
									add(new FuzzTransition(FuzzTransition.MENU, SubmitMenu));
								}
							}
						}
						else
						{
							trace ("p");
							if (Main.instance.level_select.state == false)
							{
								trace ("q");
								add(new FuzzTransition(FuzzTransition.MENU, SubmitMenu));
							}
						}
					}
				}
				else
				{
					trace ("r");
					if (Main.instance.level_select.state == false)
					{
						trace ("s");
						FP.play(Assets.VcEnding, Assets.VCVOL);
						add(new FuzzTransition(FuzzTransition.GOTO_NEXT, null, true));
					}
					else
					{
						add(new FuzzTransition(FuzzTransition.MENU, SubmitMenu));
					}
				}
			}
			else
			{
				trace ("t");
				//Stats.saveData.subTime(this.time);
				
				if (Main.instance.level_select.state == false)
				{
					trace ("u");
					add(new FuzzTransition(FuzzTransition.MENU, SubmitMenu));
				}
			}
			
			this.time = 0;
			this.countTime = false;
			
			Level.instance = null;
			
			return;
		}
		
		private function clearParticles():void
		{
			var p:Particle = null;
			var vec:Vector.<Entity> = getClass(Particle);
			for each (p in vec)
			{
				p.die();
			}
		}
		
		private function getXML():void
		{
			var o:* = Assets[Assets.PREFIXES[Stats.saveData.mode] + this.levelNum];
			
			if (o is ByteArray)
			{
				(o as ByteArray).position = 0;
			}
			
			trace (Assets.PREFIXES[Stats.saveData.mode], this.levelNum);
			
			var file:ByteArray = ((o is ByteArray) ? o : new o ());
			
			this.xml = new XML(file.readUTFBytes(file.length));
		}
		
		private function onAlarmShake():void
		{
			this.shake = false;
		}
		
		public function _goto_Next():void
		{
			this.levelNum++;
			if (this.levelNum > Assets.TOTAL_LEVELS[Stats.saveData.mode])
			{
				FP._goto_ = new EndMenu();
				return;
			}
			this.getXML();
			this.restart();
		}
		
		public function _goto_Previous():void
		{
			this.levelNum = Math.max(1, --this.levelNum);
			
			this.getXML();
			this.restart();
		}
		
		public function screenShake(time:uint, amount:uint = 2):void
		{
			this.shake = true;
			this.shakeAmount = amount;
			this.alarmShake.totalFrames = time;
			this.alarmShake.start();
		}
		
		private function build():void
		{
			var o:XML = null;
			var h:int = 0;
			var vec:Vector.<Entity> = null;
			var e:Block = null;
			var yy:int = 0;
			var t:Text = null;
			Stats.saveData.levelNum = this.levelNum;
			Stats.save();
			this.width = this.xml.width[0];
			this.height = this.xml.height[0];
			for each (o in this.xml.solids[0].rect)
			{
				if (int(o.@y) + int(o.@h) == this.height)
				{
					h = int(o.@h) + 24;
				}
				else
				{
					h = int(o.@h);
				}
				add(new Block(o.@x, o.@y, o.@w, h));
			}
			for each (o in this.xml.objects[0].children())
			{
				if (o.localName() == "player")
				{
					yy = int(o.@y) + 3;
					add(this.player = new Player(this, o.@x, yy));
					add(new Spawn(o.@x, yy));
				}
				else if (o.localName() == "electricBlock")
				{
					if (int(o.@y) + int(o.@height) == this.height)
					{
						h = int(o.@height) + 24;
					}
					else
					{
						h = int(o.@height);
					}
					add(new ElectricBlock(o.@x, o.@y, o.@width, h));
				}
				else if (o.localName() == "saw")
				{
					add(new Saw(o.@x, o.@y, o.@flip == "true"));
				}
				else if (o.localName() == "fallingPlat")
				{
					add(new FallingPlat(o.@x, o.@y, o.@width, o.@height));
				}
				else if (o.localName() == "movingPlat")
				{
					add(new MovingPlat(o.@x, o.@y, o.@width, o.@height, o.node[0].@x, o.node[0].@y, o.@speed, o.@dontMove == "true", o.@stopAtEnd == "true"));
				}
			}
			add(new Block(-8, 0, 8, this.height));
			add(new Block(0, -8, this.width, 8));
			FP.camera.setBounds(0, 0, this.width, this.height);
			FP.camera.setOrigin(160, 120);
			FP.camera.moveTo(this.player.x, this.player.y);
			vec = getClass(Block);
			for each (e in vec)
			{
				e.player = this.player;
				if (e is FallingPlat)
				{
					(e as FallingPlat).getEndY();
				}
			}
			if (Main.instance.config.OPTIONS.USE_TAS == false)
			{
				if (Main.instance.level_select.state == false)
				{
					if (Stats.saveData.mode == 0)
					{
						this.levelText = new Text("Level " + this.levelNum, 20, 20);
					}
					else
					{
						this.levelText = new Text("Hard " + this.levelNum, 20, 20);
					}
					
					this.levelText.size = 48;
				}
				else
				{
					this.levelText = new Text(Main.instance.level_select.level.name, 20, 20);
					
					this.levelText.size = 24;
				}
			}
			else
			{
				if (Main.instance.level_select.state == false)
				{
					if (Stats.saveData.mode == 0)
					{
						this.levelText = new Text("TAS Level " + this.levelNum, 20, 20);
					}
					else
					{
						this.levelText = new Text("TAS Hard " + this.levelNum, 20, 20);
					}
					
					this.levelText.size = 48;
				}
				else
				{
					this.levelText = new Text(Main.instance.level_select.level.name, 20, 20);
					
					this.levelText.size = 24;
				}
			}
			
			this.levelText.depth = 100000;
			this.levelText.color = 3355443;
			this.levelText.x = 20 + FP.camera.x;
			this.levelText.y = 20 + FP.camera.y;
			add(this.levelText);
			if (Assets.timer)
			{
				this.timer = new Text(Stats.saveData.formattedTime, 20, 60);
				this.timer.size = 24;
				this.timer.depth = 100000;
				this.timer.color = 2236962;
				this.timer.x = 20 + FP.camera.x;
				this.timer.y = 60 + FP.camera.y;
				if (Main.instance.config.OPTIONS.USE_TAS == false)
				{
					add(this.timer);
				}
			}
			if (Stats.saveData.mode == 0)
			{
				if (this.levelNum == 1)
				{
					t = new Text("LEFT / RIGHT to move\nX or S or UP to jump", 32, 146);
					t.depth = 100000;
					t.color = 3355443;
					t.size = 16;
					add(t);
					t = new Text("when jumping, hold it\nfor maximum height", 324, 128);
					t.depth = 100000;
					t.color = 3355443;
					t.size = 16;
					add(t);
					t = new Text("Z or A to grapple, then\nUP / DOWN to adjust\nand LEFT / RIGHT to swing", 704, 96);
					t.depth = 100000;
					t.color = 3355443;
					t.size = 16;
					add(t);
				}
				else if (this.levelNum == 2)
				{
					t = new Text("REMEMBER:\nZ or A to grapple, then\nUP / DOWN to adjust\nand LEFT / RIGHT to swing", 32, 116);
					t.depth = 100000;
					t.color = 3355443;
					t.size = 16;
					add(t);
				}
				else if (this.levelNum == 3)
				{
					t = new Text("RECALL:\nZ or A to grapple, then\nUP / DOWN to adjust\nand LEFT / RIGHT to swing", 56, 128);
					t.depth = 100000;
					t.color = 3355443;
					t.size = 16;
					add(t);
				}
				else if (this.levelNum == 4)
				{
					t = new Text("SERIOUSLY:\nZ or A to grapple, then\nUP / DOWN to adjust\nand LEFT / RIGHT to swing", 24, 116);
					t.depth = 100000;
					t.color = 3355443;
					t.size = 16;
					add(t);
				}
				else if (this.levelNum == 49)
				{
					t = new Text("Go for distance!", 128, 160);
					t.depth = 100000;
					t.color = 3355443;
					t.size = 16;
					add(t);
				}
			}
			add(this.bg = new Backdrop(ImgBG));
			add(new EndLine());
			if (Assets.fuzz != null)
			{
				add(Assets.fuzz);
				Assets.fuzz = null;
			}
			this.time = 0;
			this.countTime = true;
			
			Level.instance = this;
			
			TAS.Instance.Initialize((Main.instance.level.tas == 0));
			
			Main.instance.level.tas = Main.instance.level.tas;
			
			Main.instance.level.tassing = false;
			
			Main.instance.level.text = Level.instance.levelText.text;
			
			if (Main.instance.config.OPTIONS.USE_TAS == false)
			{
				if (Main.instance.level.tas == 0)
				{
				}
				else
				{
					if (Main.instance.level.tassing == false)
					{
						Main.instance.level.tas = int(Math.max(0.0, --Main.instance.level.tas));
						
						Main.instance.level.tassing = true;
						
						TAS.Instance.Open(Main.instance.level.text, Assets.PREFIXES[Stats.saveData.mode]);
					}
				}
			}
			
			return;
		}
	}
}
