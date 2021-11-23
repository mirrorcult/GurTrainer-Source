
package
{
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import jam.Level;
	import jam.Stats;
	import punk.util.Input;
	import punk.util.Key;
	
	public class TAS extends Sprite
	{
		static public var instance:TAS = null;
		
		static public function get Instance():TAS
		{
			return (TAS.instance = ((TAS.instance == null) ? new TAS() : TAS.instance));
		}
		
		public const READ:Dictionary = new Dictionary(false);
		
		public const WRITE:Dictionary = new Dictionary(false);
		
		public var read:Array = null;
		
		public var temp:Array = null;
		
		public var write:String = null;
		
		public function TAS()
		{
			super();
			
			this.READ["-"] = null;
			this.READ["+"] = {keyCode: Key.DOWN};
			this.READ["<"] = {keyCode: Key.LEFT};
			this.READ[">"] = {keyCode: Key.RIGHT};
			this.READ["^"] = {keyCode: Key.UP};
			this.READ["~"] = {keyCode: Key.ENTER};
			this.READ["Z"] = {keyCode: Key.Z};
			
			this.WRITE[null] = "\r\n";
			this.WRITE["down"] = "+";
			this.WRITE["grapple"] = "Z";
			this.WRITE["jump"] = "^";
			this.WRITE["left"] = "<";
			this.WRITE["right"] = ">";
			this.WRITE["skip"] = "~";
			this.WRITE["up"] = "^";
		}
		
		public function Initialize(flag:Boolean = false):TAS
		{
			this.read = null;
			
			this.temp = null;
			
			this.write = new String();
			
			((flag == false) ? Input.Default() : null);
			
			return this;
		}
		
		public function Open(level:String, mode:String):TAS
		{
			var file:File = null;
			
			var file_name:String = null;
			
			var file_stream:FileStream = null;
			
			var files:Array = null;
			
			var read:String = null;
			
			File.applicationStorageDirectory.resolvePath("TAS/" + mode).createDirectory();
			
			this.Initialize();
			
			files = File.applicationStorageDirectory.resolvePath("TAS/" + mode).getDirectoryListing().sortOn("name");
			
			for each (file in files)
			{
				if (file.name.indexOf(level, 0) == -1)
				{
					file = null;
					
					continue;
				}
				else
				{
					if (file.name.split("_")[1] == level)
					{
						break;
					}
				}
			}
			
			if ((file == null) || (file.exists == false))
			{
			}
			else
			{
				file_stream = new FileStream();
				
				file_stream.open(file, FileMode.READ);
				{
					read = file_stream.readUTFBytes(file_stream.bytesAvailable);
				}
				file_stream.close();
				
				this.read = read.split("\r\n");
				
				this.temp = null;
			}
			
			return this;
		}
		
		public function Read():TAS
		{
			var r:Object = null;
			
			var read:Array = null;
			
			if (this.read == null)
			{
			}
			else
			{
				for each (r in this.temp)
				{
					r = this.READ[r];
					
					((r == null) ? null : Input.onKeyUp(r));
				}
				
				if (this.read.length == 0)
				{
					read = null;
				}
				else
				{
					read = this.read.shift().split("");
				}
				
				for each (r in read)
				{
					r = this.READ[r];
					
					((r == null) ? null : Input.onKeyDown(r));
				}
				
				this.temp = read;
				
				if (this.temp == null)
				{
					this.read = null;
				}
			}
			
			return this;
		}
		
		public function Save(level:String, mode:String):TAS
		{
			var file:File = null;
			
			var file_stream:FileStream = null;
			
			var time:String = null;
			
			var write:Object = null;
			
			File.applicationStorageDirectory.resolvePath("TAS/" + mode).createDirectory();
			
			write = this.write.split ("\r\n");
			
			while (write.length != Main.instance.level.time)
			{
				if (write.length < Main.instance.level.time)
				{
					write.unshift (null);
				}
				else if (write.length > Main.instance.level.time)
				{
					write.shift ();
				}
			}
			
			time = Stats.saveData.getTimePlusX (write.length, ".");
			
			file_stream = new FileStream();
			
			file = File.applicationStorageDirectory.resolvePath("TAS/" + mode + "/" + "TAS_" + level + "_" + time + ".txt");
			
			file = new File (file.nativePath);
			
			write = write.join ("\r\n");
			
			file_stream.open(file, FileMode.WRITE);
			file_stream.writeUTFBytes(String(write));
			file_stream.close();
			
			return this;
		}
		
		public function Write(input:String):TAS
		{
			//if (this.read == null)
			{
				input = this.WRITE[input];
				
				input = ((input == null) ? "" : input);
				
				this.write = (this.write + input);
			}
			
			return this;
		}
	}
}
