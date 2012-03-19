package org.aerialframework.abstract
{
	import avmplus.getQualifiedClassName;
	
	import com.mysql.workbench.FileWriter;
	import com.mysql.workbench.model.Schema;
	
	import flash.events.EventDispatcher;
	
	import org.aerialframework.event.CodeGenEvent;

	public class AbstractPlugin extends EventDispatcher
	{
		private var _schema:Schema;
		private var _options:Object;
		private var _relationships:XML;
		
		private var _fw:FileWriter = new FileWriter();
		
		public function AbstractPlugin(schema:Schema, options:Object=null, relationships:XML=null)
		{
			_schema 			= schema;
			if(options) 		_options = options;
			if(relationships) 	_relationships = relationships;
			
			initialize();
		}
		
		protected function initialize():void
		{
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
		 * @Override
		 */
		public function generate():void
		{
		}
		
		protected function notify(filePackage:String, fileName:String, fileContent:String):void
		{
			//Dispatch an event containing the generated content.
			var codegenEvent:CodeGenEvent = new CodeGenEvent(CodeGenEvent.CREATED);
			
			if(!this.fileType)
				throw new Error("'fileType' property not set on " + getQualifiedClassName(this));
			
			codegenEvent.fileType 		= this.fileType;
			codegenEvent.filePackage 	= filePackage;
			codegenEvent.fileName 		= fileName;
			codegenEvent.fileContent 	= fileContent;
			
			dispatchEvent(codegenEvent);
		}
		
		/**
		 * @Override
		 */
		protected function get fileType():String
		{
			return null;
		}

		public function get fw():FileWriter
		{
			return _fw;
		}
	}
}