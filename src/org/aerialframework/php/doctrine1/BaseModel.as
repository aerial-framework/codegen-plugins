package org.aerialframework.php.doctrine1
{
	import com.mysql.workbench.Inflector;
	import com.mysql.workbench.model.Column;
	import com.mysql.workbench.model.DomesticKey;
	import com.mysql.workbench.model.ForeignKey;
	import com.mysql.workbench.model.Index;
	import com.mysql.workbench.model.Schema;
	import com.mysql.workbench.model.Table;

	import org.aerialframework.abstract.AbstractPlugin;
	import org.aerialframework.abstract.GeneratedFile;

	public class BaseModel extends AbstractPlugin
	{		
		public static const PACKAGE:String = "package";
		public static const TABLES:String = "tables";
		public static const BASE_FOLDER_NAME:String = "baseFolderName";
		
		private var modelsPackage:String;
		private var tables:Array;
		private var folderName:String;
		
		public function BaseModel(schema:Schema, options:Object=null, relationships:XML=null)
		{
			super(schema, options, relationships);
		}
		
		override protected function initialize():void
		{
			modelsPackage = options.hasOwnProperty(PACKAGE) ? options[PACKAGE] : "org.aerialframework.vo";
			tables = options.hasOwnProperty(TABLES) ? options[TABLES] : null;
			folderName = options.hasOwnProperty(BASE_FOLDER_NAME) ? options[BASE_FOLDER_NAME] : "base";
		}
		
		override protected function get fileType():String
		{
			return "php-doctrine1-basemodel";
		}
		
		override public function generate():Array
		{
			return generateBaseModels();
		}
		
		private function generateBaseModels():Array
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
				fw.add('abstract class '+ Inflector.ucfirst(this.folderName) + table.className +' extends Aerial_Record').newLine();
				fw.add('{').newLine().indentForward();
				fw.add('public function setTableDefinition()').newLine();
				fw.add('{').newLine().indentForward();
				fw.add("$this->setTableName('"+ table.name +"');").newLine();
				
				//Properties
				for each (var column:Column in table.columns)
				{
					fw.add("$this->hasColumn('"+ column.name +"', '"+column.rawType+"', "+column.typeLength+", array(").newLine().indentForward();
					fw.add("'type' => '"+column.rawType+"',").newLine();
					if(column.type == "enum")
					{
						fw.add("'values' =>").newLine().add("array(").newLine();
						var enums:Array  = String(column.dataTypeExplicitParams.match(/(?<=\().*(?=\))/).shift()).split(",");						
						for (var i:int = 0; i < enums.length; i++) 
						{
							fw.add(" "+ i.toString() +" => "+ enums[i]+",").newLine();
						}
						fw.add("),").newLine();
					}
					if(column.isPrimary)
						fw.add("'primary' => true,").newLine();
					if(column.autoIncrement)
						fw.add("'autoincrement' => true,").newLine();
					if(column.isNotNull && !column.isPrimary)
						fw.add("'notnull' => true,").newLine();
					if(column.isUnique && !column.isPrimary)
						fw.add("'unique' => true,").newLine();
					//Default value is a mess in MWB because of system constants.  Strings can be entered w/ or w/o quotes.
					//i.e., CURRENT_TIMESTAMP and 'pending'
					if(column.defaultValue && isNaN(Number(column.defaultValue)))
						fw.add("'default' => '"+ column.defaultValue +"',").newLine();
					else if(column.defaultValue)
						fw.add("'default' => "+ column.defaultValue +",").newLine();
					if(column.typeLength)
						fw.add("'length' => '"+column.typeLength+"',").newLine();
					fw.add("));").newLine().indentBack();
				}
				fw.newLine();
				
				//Indexes
				for each(var index:Index in table.indices)
				{  
					if(index.indexType != "INDEX")
						continue;
					fw.add("$this->index('"+ index.name +"', array(").newLine().indentForward();
					fw.add("'fields' => ").newLine();
					fw.add("array(").newLine();
					for (var j:int = 0; j < index.columns.length; j++) 
					{
						fw.add(" 0 => '"+Column(index.columns[j]).name+"',").newLine();
					}
					fw.add("),").newLine();
					fw.add("));").newLine().indentBack();
				}
				fw.newLine();
				
				//Collation
				fw.add("$this->option('collate', '"+ schema.defaultCollationName +"');").newLine();
				fw.add("$this->option('charset', '"+ schema.defaultCharacterSetName +"');").newLine();
				fw.add("$this->option('type', '"+ table.engine +"');").newLine().indentBack();
				
				fw.add("}").newLine(2);
				
				//Relationships
				fw.add("public function setUp()").newLine();
				fw.add("{").newLine().indentForward();
				fw.add("parent::setUp();").newLine();
				
				for each(var fk:ForeignKey in table.foreignKeys)
				{  
					fw.add("$this->hasOne('" + fk.referencedTable.className
						+(fk.columnClassName != fk.referencedTable.className ? " as "+ fk.columnClassName : "")
						+"', array(").newLine().indentForward();
					fw.add("'local' => '"+ fk.column.name +"',").newLine();
					fw.add("'foreign' => '"+ fk.referencedColumn.name +"'));").newLine().indentBack();
				}
				
				var alias:String;
				var aliases:Array = new Array();
				for each(var dk:DomesticKey in table.domesticKeys)
				{
					//There's a possibility of repeating aliases in cases like self referencing using a refClass.
					alias = Inflector.pluralCamelize(dk.referencedTable.className);
					if(!aliases["_" + alias])
						aliases["_" + alias] = 1;
					else
						aliases["_" + alias]++;
					
					fw.add("$this->hasMany('"+ dk.referencedTable.className +" as "+ alias + (aliases["_" + alias] > 1 ? aliases["_" + alias] : "" ) +"', array(").newLine().indentForward();
					fw.add("'local' => '"+ Column(table.primaryKey.columns[0]).name +"',").newLine();
					fw.add("'foreign' => '"+ dk.referencedColumn.name +"'));").newLine().indentBack();
				}
				
				//Custom Relationships: Many
				var tableName:String = table.name;
				for each(var xmlMN:XML in relationships.mn.(table.(text() == tableName).parent()))
				{
					var t1:XML = xmlMN.table.(text() == tableName)[0];
					var t2:XML = xmlMN.table.(text() != tableName)[0];
					alias = (t2.attribute("alias").length() > 0 ? t2.attribute("alias") : t2.text());
					
					fw.add("$this->hasMany('"+ t2.text() +" as "+ Inflector.pluralCamelize(alias) +"', array(").newLine().indentForward();
					fw.add("'refClass' => '"+ xmlMN.@joinTable +"',").newLine();
					fw.add("'local' => '"+ t1.@fk +"',").newLine();
					fw.add("'foreign' => '"+ t2.@fk +"'));").newLine().indentBack();
				}
				
				//Custom Relationships: Self
				for each(var xmlSelf:XML in relationships.self.(@table == tableName))
				{
					for each(var xmlFK:XML in xmlSelf.fk)
					{
						fw.add("$this->hasMany('"+ table.name +" as "+ Inflector.pluralCamelize(xmlFK.@alias) +"', array(").newLine().indentForward();
						fw.add("'refClass' => '"+ xmlSelf.@joinTable +"',").newLine();
						fw.add("'local' => '"+ table.primaryKey.columns[0].name +"',").newLine();
						fw.add("'foreign' => '"+ xmlFK.text() +"'));").newLine().indentBack();
					}
				}
				
				fw.indentBack().add("}").newLine(2); //Close Relationships
				
				//_explicitType
				fw.add("public function construct()").newLine();
				fw.add("{").newLine().indentForward();
				fw.add("$this->mapValue('_explicitType', '"+this.modelsPackage+"."+table.className+"');").newLine().indentBack();
				fw.add("}").newLine().indentBack();
				
				fw.add("}");//Close Class
				
				var modelName:String = Inflector.ucfirst(this.folderName) + table.className + ".php";
				files.push(new GeneratedFile(this.fileType, this.modelsPackage + "." + this.folderName, modelName, fw.stream));
				
			}//End Table Loop
			
			return files;
		}
	}
}