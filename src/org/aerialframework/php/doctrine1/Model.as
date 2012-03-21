package org.aerialframework.php.doctrine1
{
	import com.mysql.workbench.Inflector;
	import com.mysql.workbench.model.Schema;
	import com.mysql.workbench.model.Table;

	import org.aerialframework.abstract.AbstractPlugin;
	import org.aerialframework.abstract.GeneratedFile;

	public class Model extends AbstractPlugin
	{
		public static const PACKAGE:String = "package";
		public static const TABLES:String = "tables";
		public static const BASE_FOLDER_NAME:String = "baseFolderName";
		
		private var modelsPackage:String;
		private var tables:Array;
		private var folderName:String;
		
		public function Model(schema:Schema, options:Object=null, relationships:XML=null)
		{
			super(schema, options, relationships);
		}
		
		override protected function initialize():*
		{
			modelsPackage = options.hasOwnProperty(PACKAGE) ? options[PACKAGE] : "org.aerialframework.vo";
			tables = options.hasOwnProperty(TABLES) ? options[TABLES] : null;
			folderName = options.hasOwnProperty(BASE_FOLDER_NAME) ? options[BASE_FOLDER_NAME] : "base";
		}
		
		override protected function get fileType():*
		{
			return "php-doctrine1-model";
		}
		
		override public function generate():Array
		{
			return generateModels();
		}
		
		private function generateModels():Array
		{
			if(!modelsPackage)
				throw new Error("'modelPackage' not set.");	
			
			var table:Table;
			var files:Array = [];
			
			for each (table in schema.tables)
			{
				if(tables && (tables.indexOf(table.name) == -1))
					continue;
				fw.clear();
				fw.add('<?php').newLine(2);
				fw.add('class ' + table.className + ' extends ' + Inflector.ucfirst(this.folderName) + table.className).newLine();
				fw.add('{').newLine(2);
				fw.add('}');
				
				files.push(new GeneratedFile(this.fileType, this.modelsPackage, table.className + ".php", fw.stream));
			}
			
			return files;
		}
	}
}