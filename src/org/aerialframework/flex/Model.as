package org.aerialframework.flex
{
	import com.mysql.workbench.Inflector;
	import com.mysql.workbench.model.Column;
	import com.mysql.workbench.model.DomesticKey;
	import com.mysql.workbench.model.ForeignKey;
	import com.mysql.workbench.model.Schema;
	import com.mysql.workbench.model.Table;
	
	import org.aerialframework.abstract.AbstractPlugin;
	import org.aerialframework.abstract.GeneratedFile;

	import util.ActionScriptUtil;
	
	public class Model extends AbstractPlugin
	{
		public static const PACKAGE:String = "package";
		public static const TABLES:String = "tables";
		public static const SUFFIX:String = "suffix";
		
		private var modelsPackage:String;
		private var tables:Array;
		private var suffix:String;
		
		public function Model(schema:Schema, options:Object=null, relationships:XML=null)
		{
			super(schema, options, relationships);
		}
		
		override protected function initialize():void
		{
			modelsPackage = options.hasOwnProperty(PACKAGE) ? options[PACKAGE] : "org.aerialframework.vo";
			tables = options.hasOwnProperty(TABLES) ? options[TABLES] : null;
			suffix = options.hasOwnProperty(SUFFIX) ? options[SUFFIX] : "VO";
		}
		
		override protected function get fileType():String
		{
			return "flex-model";
		}
		
		override public function generate():Array
		{
			return generateModels();
		}
		
		private function generateModels():Array
		{
			if(!modelsPackage || !suffix)
				throw new Error("'modelsPackage' or 'suffix' are not set.");	
			
			//loop vars
			var column:Column;
			var fk:ForeignKey;
			var dk:DomesticKey;
			var table:Table
			var tmpName:String;
			var as3Type:String;
			var t1:XML;
			var t2:XML
			var xmlMN:XML;
			var xmlSelf:XML;
			var xmlFK:XML
			var alias:String;
			var aliases:Array = new Array();
			
			var files:Array = [];
			
			for each (table in schema.tables)
			{
				if(tables && (tables.indexOf(table.name) == -1))
					continue;
				
				var tableName:String = table.name; //e4x var
				
				fw.clear();
				fw.add("package " + modelsPackage).newLine();
				fw.add("{").newLine().indentForward();
				fw.add("import org.aerialframework.rpc.AbstractVO;").newLine();
				fw.add("import "+this.modelsPackage+".*;").newLine(2);
				fw.add("import flash.events.Event;").newLine();
				fw.add("import mx.collections.ArrayCollection;").newLine();
				fw.add("import flash.utils.ByteArray;").newLine(2);
				fw.add("[Bindable]").newLine();
				fw.add('[RemoteClass(alias="'+ this.modelsPackage +"."+ table.className +'")]').newLine();
				fw.add("public class "+ table.className + this.suffix +" extends AbstractVO").newLine();
				fw.add("{").newLine().indentForward();
				fw.add("public function "+table.className + this.suffix+"()").newLine();
				fw.add("{").newLine().indentForward();
				fw.add("super(function(field:String):*{return this[field]},").newLine().indentForward();
				fw.add("function(field:String, value:*):void{this[field] = value});").newLine().indentBack(2);
				fw.add("}").newLine(2);
				
				//Private vars
				for each (column in table.columns)
				{
					fw.add("private var _" + column.name + ":*;").newLine();
				}
				
				//Private vars: One 
				for each(fk in table.foreignKeys)
				{
					fw.add("private var _" + fk.columnClassName + ":*;").newLine();
				}
				
				//Private vars: Many
				aliases = new Array();
				for each(dk in table.domesticKeys)
				{
					//There's a possibility of repeating aliases in cases like self referencing using a refClass.
					alias = Inflector.pluralCamelize(dk.referencedTable.className);
					if(!aliases["_" + alias])
						aliases["_" + alias] = 1;
					else
						aliases["_" + alias]++;
					tmpName = alias + (aliases["_" + alias] > 1 ? aliases["_" + alias] : "" );
					
					fw.add("private var _"+ tmpName + ":*;").newLine();
				}
				
				//Private vars: Custom Many
				for each(xmlMN in relationships.mn.(table.(text() == tableName).parent()))
				{
					t1 = xmlMN.table.(text() == tableName)[0];
					t2 = xmlMN.table.(text() != tableName)[0];
					alias = (t2.attribute("alias").length() > 0 ? t2.attribute("alias") : t2.text());
					
					fw.add("private var _"+ Inflector.pluralCamelize(alias) + ":*;").newLine();
				}
				
				//Private vars: Custom Self
				for each(xmlSelf in relationships.self.(@table == tableName))
				{
					for each(xmlFK in xmlSelf.fk)
					{
						fw.add("private var _"+ Inflector.pluralCamelize(xmlFK.@alias) + ":*;").newLine();
					}
				}
				
				//Getters & Setters
				for each (column in table.columns)
				{
					fw.newLine();
					as3Type = ActionScriptUtil.getAS3Type(column.rawType);
					
					fw.add("public function get "+ column.name +"():" + as3Type).newLine();
					fw.add("{").newLine().indentForward();
					fw.add("return _" + column.name).newLine().indentBack();
					fw.add("}").newLine(2);
					
					fw.add("public function set "+ column.name +"(value:"+ as3Type +"):void").newLine();
					fw.add("{").newLine().indentForward();
					fw.add("_" + column.name + " = value;").newLine().indentBack();
					fw.add("}").newLine();
				}
				
				//Getters & Setters: One
				for each(fk in table.foreignKeys)
				{
					fw.newLine();
					
					fw.add("public function get "+ fk.columnClassName +"():"+ fk.referencedTable.className + this.suffix +"").newLine();
					fw.add("{").newLine().indentForward();
					fw.add("return _"+ fk.columnClassName +";").newLine().indentBack();
					fw.add("}").newLine(2);
					
					fw.add("public function set "+ fk.columnClassName +"(value:"+fk.referencedTable.className + this.suffix+"):void").newLine();
					fw.add("{").newLine().indentForward();
					fw.add("_"+ fk.columnClassName +" = value;").newLine().indentBack();
					fw.add("}").newLine();
				}
				
				//Getters & Setters: Many
				aliases = new Array();
				for each(dk in table.domesticKeys)
				{
					//There's a possibility of repeating aliases in cases like self referencing using a refClass.
					alias = Inflector.pluralCamelize(dk.referencedTable.className);
					if(!aliases["_" + alias])
						aliases["_" + alias] = 1;
					else
						aliases["_" + alias]++;
					
					tmpName = alias + (aliases["_" + alias] > 1 ? aliases["_" + alias] : "" );
					fw.newLine();
					
					fw.add("public function get "+ tmpName +"():ArrayCollection").newLine();
					fw.add("{").newLine().indentForward();
					fw.add("return _" +  tmpName + ";").newLine().indentBack();
					fw.add("}").newLine(2);
					
					fw.add("public function set "+ tmpName +"(value:ArrayCollection):void").newLine();
					fw.add("{").newLine().indentForward();
					fw.add("_" + tmpName + " = value;").newLine().indentBack();
					fw.add("}").newLine();
				}
				
				//Custom Relationships: Many
				for each(xmlMN in relationships.mn.(table.(text() == tableName).parent()))
				{
					t1 = xmlMN.table.(text() == tableName)[0];
					t2 = xmlMN.table.(text() != tableName)[0];
					alias = (t2.attribute("alias").length() > 0 ? t2.attribute("alias") : t2.text());
					
					tmpName = Inflector.pluralCamelize(alias);
					fw.newLine();
					fw.add("public function get "+ tmpName +"():ArrayCollection").newLine();
					fw.add("{").newLine().indentForward();
					fw.add("return _" +  tmpName + ";").newLine().indentBack();
					fw.add("}").newLine(2);
					
					fw.add("public function set "+ tmpName +"(value:ArrayCollection):void").newLine();
					fw.add("{").newLine().indentForward();
					fw.add("_" + tmpName + " = value;").newLine().indentBack();
					fw.add("}").newLine();
				}
				
				//Custom Relationships: Self
				for each(xmlSelf in relationships.self.(@table == tableName))
				{
					for each(xmlFK in xmlSelf.fk)
					{
						tmpName = Inflector.pluralCamelize(xmlFK.@alias);
						fw.newLine();
						fw.add("public function get "+ tmpName +"():ArrayCollection").newLine();
						fw.add("{").newLine().indentForward();
						fw.add("return _" +  tmpName + ";").newLine().indentBack();
						fw.add("}").newLine(2);
						
						fw.add("public function set "+ tmpName +"(value:ArrayCollection):void").newLine();
						fw.add("{").newLine().indentForward();
						fw.add("_" + tmpName + " = value;").newLine().indentBack();
						fw.add("}").newLine();
					}
				}
				
				fw.indentBack().add("}").newLine().indentBack().add("}"); //Close class
				
				files.push(new GeneratedFile(this.fileType, this.modelsPackage, table.className + this.suffix + ".as", fw.stream));
			}
			
			return files;
		}		
	}
}