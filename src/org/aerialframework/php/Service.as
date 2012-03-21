package org.aerialframework.php
{
	import com.mysql.workbench.model.Table;

	import org.aerialframework.abstract.AbstractPlugin;
	import org.aerialframework.abstract.GeneratedFile;

	public class Service extends AbstractPlugin
	{
		public static const PACKAGE:String = "package";
		public static const TABLES:String = "tables";
		public static const SUFFIX:String = "suffix";
		
		private var servicesPackage:String;
		private var tables:Array;
		private var suffix:String;
		
		override public function initialize():*
		{
			servicesPackage = options.hasOwnProperty(PACKAGE) ? options[PACKAGE] : "org.aerialframework.service";
			tables = options.hasOwnProperty(TABLES) ? options[TABLES] : null;
			suffix = options.hasOwnProperty(SUFFIX) ? options[SUFFIX] : "Service";
		}
		
		override protected function get fileType():*
		{
			return "php-doctrine1-service";
		}
		
		override public function generate():*
		{
			return generateServices();
		}
		
		private function generateServices():Array
		{
			if(!servicesPackage)
				throw new Error("'servicePackage' not set.");	
			
			var table:Table;
			var files:Array = [];

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
				
				files.push(new GeneratedFile(this.fileType, this.servicesPackage, table.className + suffix + ".php", fw.stream));
			}
			
			return files;
		}
	}
}