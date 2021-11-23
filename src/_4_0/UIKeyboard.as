
package _4_0
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.sampler.NewObjectSample;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class UIKeyboard extends Sprite
	{
		static public var instance:UIKeyboard = null;
		
		static public function get Instance():UIKeyboard
		{
			return (UIKeyboard.instance = ((UIKeyboard.instance == null) ? new UIKeyboard() : UIKeyboard.instance));
		}
		
		public var config:Object = null;
		
		public var ui_down:Sprite = null;
		
		public var ui_left:Sprite = null;
		
		public var ui_right:Sprite = null;
		
		public var ui_up:Sprite = null;
		
		public var ui_z:Sprite = null;
		
		public function UIKeyboard ()
		{
			super ();
		}
		
		public function DeInitialize () : UIKeyboard
		{
			this.removeEventListener (Event.ADDED_TO_STAGE, this.HandleEvent, false);
			
			this.removeChildren (0, int.MAX_VALUE);
			
			return this;
		}
		
		public function HandleEvent (event:Event) : UIKeyboard
		{
			switch (event.currentTarget)
			{
				case this :
				{
					switch (event.type)
					{
						case Event.ADDED_TO_STAGE :
						{
							this.Position ();
							
							break;
						}
						default :
						{
							break;
						}
					}
					
					break;
				}
				default :
				{
					break;
				}
			}
			
			return this;
		}
		
		public function Initialize (config:Object) : UIKeyboard
		{
			this.DeInitialize ();
			
			this.config = config;
			
			this.ui_down = this.UI ("DOWN", this.config.BOX_SIZE, this.config.BOX_SIZE, this.config.BOX_SIZE);
			
			this.ui_left = this.UI ("LEFT", this.config.BOX_SIZE, 0.0, this.config.BOX_SIZE);
			
			this.ui_right = this.UI ("RIGHT", this.config.BOX_SIZE, (this.config.BOX_SIZE * 2.0), this.config.BOX_SIZE);
			
			this.ui_up = this.UI ("UP", this.config.BOX_SIZE, this.config.BOX_SIZE, 0.0);
			
			this.ui_z = this.UI ("Z", this.config.BOX_SIZE, 0.0, 0.0);
			
			this.addChild (this.ui_down);
			this.addChild (this.ui_left);
			this.addChild (this.ui_right);
			this.addChild (this.ui_up);
			this.addChild (this.ui_z);
			
			this.addEventListener (Event.ADDED_TO_STAGE, this.HandleEvent, false, 0, false);
			
			return this;
		}
		
		public function InputDown (input:String) : UIKeyboard
		{
			var ui:Object = null;
			
			input = input.toLowerCase ();
			
			switch (input)
			{
				case "+" :
				{
					input = "down";
					
					break;
				}
				case "<" :
				{
					input = "left";
					
					break;
				}
				case ">" :
				{
					input = "right";
					
					break;
				}
				case "^" :
				{
					input = "up";
					
					break;
				}
				case "z" :
				{
					input = "z";
					
					break;
				}
				default :
				{
					break;
				}
			}
			
			ui = this.getChildByName ("ui_" + input);
			
			if (ui == null)
			{
			}
			else
			{
				//trace ("INPUT DOWN", ui, input);
				
				//ui.alpha = 0.5;
				
				ui.getChildByName ("ui_overlay").visible = true;
			}
			
			return this;
		}
		
		public function InputUp (input:String) : UIKeyboard
		{
			var ui:Object = null;
			
			input = input.toLowerCase ();
			
			switch (input)
			{
				case "+" :
				{
					input = "down";
					
					break;
				}
				case "<" :
				{
					input = "left";
					
					break;
				}
				case ">" :
				{
					input = "right";
					
					break;
				}
				case "^" :
				{
					input = "up";
					
					break;
				}
				case "z" :
				{
					input = "z";
					
					break;
				}
				default :
				{
					break;
				}
			}
			
			ui = this.getChildByName ("ui_" + input);
			
			if (ui == null)
			{
			}
			else
			{
				//trace ("INPUT UP", ui, input);
				
				//ui.alpha = 1.0;
				
				ui.getChildByName ("ui_overlay").visible = false;
			}
			
			return this;
		}
		
		public function Position () : UIKeyboard
		{
			var position:Array = this.config.POSITION.toUpperCase ().split ("_");
			
			this.x = 0.0;
			this.y = 0.0;
			
			switch (position [0])
			{
				case "LEFT" :
				{
					this.x = 0.0;
					
					break;
				}
				case "MIDDLE" :
				{
					this.x = ((this.parent.width - this.width) * 0.5);
					
					break;
				}
				case "RIGHT" :
				{
					this.x = (this.parent.width - this.width);
					
					break;
				}
				default:
				{
					break;
				}
			}
			
			switch (position [1])
			{
				case "BOTTOM" :
				{
					this.y = (this.parent.height - this.height);
					
					break;
				}
				case "MIDDLE" :
				{
					this.y = ((this.parent.height - this.height) * 0.5);
					
					break;
				}
				case "TOP" :
				{
					this.y = 0.0;
					
					break;
				}
				default:
				{
					break;
				}
			}
			
			return this;
		}
		
		public function UI (text:String, size:Number, x:Number, y:Number) : Sprite
		{
			var t:String = text;
			
			var text_field:TextField = new TextField ();
			
			var text_format:TextFormat = new TextFormat (null, this.config.FONT_SIZE, uint (this.config.FONT_COLOR), false, false, false, null, null, TextFormatAlign.CENTER, null, null, null, null);
			
			var ui:Sprite = new Sprite ();
			
			var ui_overlay:Sprite = new Sprite ();
			
			ui.graphics.beginFill (0x000000, 0.5);
			ui.graphics.drawRect (0.0, 0.0, size, size);
			ui.graphics.endFill ();
			
			ui.graphics.beginFill (uint (this.config.BOX_COLOR), 1.0);
			ui.graphics.drawRect (2.0, 2.0, (size - 4.0), (size - 4.0));
			ui.graphics.endFill ();
			
			ui_overlay.graphics.beginFill (uint (this.config.BOX_COLOR_PRESSED), 0.5);
			ui_overlay.graphics.drawRect (0.0, 0.0, size, size);
			ui_overlay.graphics.endFill ();
			
			text = text.toUpperCase ();
			
			switch (text)
			{
				case "DOWN" :
				{
					text = "D";
					
					text_format.font = "Arrows";
					
					break;
				}
				case "LEFT" :
				{
					text = "B";
					
					text_format.font = "Arrows";
					
					break;
				}
				case "RIGHT" :
				{
					text = "A";
					
					text_format.font = "Arrows";
					
					break;
				}
				case "UP" :
				{
					text = "C";
					
					text_format.font = "Arrows";
					
					break;
				}
				case "Z" :
				{
					text = "";
					
					text_format.font = "04b03";
					
					break;
				}
				default :
				{
					break;
				}
			}
			
			text_field.autoSize = TextFieldAutoSize.CENTER;
			text_field.defaultTextFormat = text_format;
			text_field.embedFonts = true;
			text_field.selectable = false;
			text_field.text = text;
			text_field.textColor = uint (text_format.color);
			text_field.x = ((ui.width * 0.5) - (text_field.width * 0.5));
			text_field.y = ((ui.height * 0.5) - (text_field.height * 0.5));
			
			ui.name = ("ui_" + t).toLowerCase ();
			ui.x = x;
			ui.y = y;
			
			ui_overlay.name = "ui_overlay";
			ui_overlay.visible = false;
			
			ui.addChild (text_field);
			ui.addChild (ui_overlay);
			
			return ui;
		}
	}
}
