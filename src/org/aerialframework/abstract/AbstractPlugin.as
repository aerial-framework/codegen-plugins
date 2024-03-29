package org.aerialframework.abstract
{
	import com.mysql.workbench.FileWriter;
	import com.mysql.workbench.model.Schema;

	import flash.events.EventDispatcher;

	public class AbstractPlugin extends EventDispatcher
	{
		private var _schema:Schema;
		private var _options:Object = {};
		private var _relationships:XML;
		
		private var _fw:FileWriter = new FileWriter();
		
		public function AbstractPlugin()
		{
			_schema 			= schema;
			_options 			= options ? options : {};
			_relationships 		= relationships ? relationships : new XML();
			
			initialize();
		}
		
		public function initialize():*
		{
		}

		public function get language():*
		{
			return "Unspecified";
		}

		public function get exposedOptions():*
		{
			return null;
		}

		public function get schema():Schema
		{
			return _schema;
		}

		public function set schema(value:Schema):void
		{
			_schema = value;
		}

		public function get options():Object
		{
			return _options;
		}

		public function set options(value:Object):void
		{
			_options = value;
		}
		
		public function get relationships():XML
		{
			return _relationships;
		}
		
		public function set relationships(value:XML):void
		{
			_relationships = value;
		}
		
		public function set lineEnding(e:String):void
		{
			_fw.lineEnding = e;
		}
		
		public function get lineEnding():String
		{
			return _fw.lineEnding;
		}
		
		/**
		 * Returns an Array of GeneratedFile instances
		 *
		 * @Override
		 */
		public function generate():*
		{
			return [];
		}
		
		/**
		 * @Override
		 */
		public function get fileType():*
		{
			return null;
		}

		public function get fw():FileWriter
		{
			return _fw;
		}
	}
}