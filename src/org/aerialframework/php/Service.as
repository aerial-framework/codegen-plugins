package org.aerialframework.php
{
	import com.mysql.workbench.Inflector;
	import com.mysql.workbench.model.Schema;
	import com.mysql.workbench.model.Table;
	
	import org.aerialframework.abstract.AbstractPlugin;
	
	public class Service extends AbstractPlugin
	{
		public static const PACKAGE:String = "package";
		public static const TABLES:String = "tables";
		public static const SUFFIX:String = "suffix";
		
		private var servicesPackage:String;
		private var tables:Array;
		private var suffix:String;
		
		public function Service(schema:Schema, options:Object=null, relationships:XML=null)
		{
			super(schema, options, relationships);
		}
		
		override protected function initialize():void
		{
			servicesPackage = options.hasOwnProperty(PACKAGE) ? options[PACKAGE] : "org.aerialframework.service";
			tables = options.hasOwnProperty(TABLES) ? options[TABLES] : null;
			suffix = options.hasOwnProperty(SUFFIX) ? options[SUFFIX] : "Service";
		}
		
		override protected function get fileType():String
		{
			return "php-doctrine1-service";
		}
		
		override public function generate():void
		{
			generateServices();
		}
		
		private function generateServices():void
		{
			if(!servicesPackage)
				throw new Error("'servicePackage' not set.");	
			
			var table:Table
			for each (table in schema.tables)
			{
				if(tables && (tables.indexOf(table.name) == -1))
					continue;
				fw.clear();
				fw.add('<?php').newLine();
				fw.indentForward().add('import("aerialframework.service.AbstractService");').newLine(2);
				fw.add('class ' + table.name + suffix + ' extends AbstractService').newLine().add('{').newLine();
				fw.indentForward().add('public $modelName = "'+ table.className +'";').newLine();
				fw.indentBack().add('}').newLine();
				fw.indentBack().add('?>').newLine(3);
				
				notify(this.servicesPackage, table.className + suffix + ".php", fw.stream);
			}
		}
	}
}