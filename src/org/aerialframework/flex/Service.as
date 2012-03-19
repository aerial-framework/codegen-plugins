package org.aerialframework.flex
{
	import com.mysql.workbench.Inflector;
	import com.mysql.workbench.model.Column;
	import com.mysql.workbench.model.DomesticKey;
	import com.mysql.workbench.model.ForeignKey;
	import com.mysql.workbench.model.Schema;
	import com.mysql.workbench.model.Table;
	
	import org.aerialframework.abstract.AbstractPlugin;
	
	import util.ActionScriptUtil;
	
	public class Service extends AbstractPlugin
	{
		public static const MODEL_PACKAGE:String = "modelPackage";
		public static const SERVICE_PACKAGE:String = "servicePackage";
		public static const BOOTSTRAP_PACKAGE:String = "bootstrapPackage";
		public static const TABLES:String = "tables";
		public static const MODEL_SUFFIX:String = "modelSuffix";
		public static const SERVICE_SUFFIX:String = "serviceSuffix";
		
		private var modelPackage:String;
		private var servicePackage:String;
		private var bootstrapPackage:String;
		private var tables:Array;
		private var modelSuffix:String;
		private var serviceSuffix:String;
		
		public function Service(schema:Schema, options:Object=null, relationships:XML=null)
		{
			super(schema, options, relationships);
		}
		
		override protected function initialize():void
		{
			modelPackage = options.hasOwnProperty(MODEL_PACKAGE) ? options[MODEL_PACKAGE] : "org.aerialframework.vo";
			servicePackage = options.hasOwnProperty(SERVICE_PACKAGE) ? options[SERVICE_PACKAGE] : "org.aerialframework.service";
			bootstrapPackage = options.hasOwnProperty(BOOTSTRAP_PACKAGE) ? options[BOOTSTRAP_PACKAGE] : "org.aerialframework.bootstrap";
			tables = options.hasOwnProperty(TABLES) ? options[TABLES] : null;
			modelSuffix = options.hasOwnProperty(MODEL_SUFFIX) ? options[MODEL_SUFFIX] : "VO";
			serviceSuffix = options.hasOwnProperty(SERVICE_SUFFIX) ? options[SERVICE_SUFFIX] : "Service";
		}
		
		override protected function get fileType():String
		{
			return "flex-service";
		}
		
		override public function generate():void
		{
			generateServices();
		}
		
		private function generateServices():void
		{
			if(!servicePackage || !modelPackage)
				throw new Error("'servicePackage' or 'modelPackage' are not set.");	
			
			var table:Table
			var serviceClass:String;
			var modelClass:String;
			for each (table in schema.tables)
			{
				if(tables && (tables.indexOf(table.name) == -1))
					continue;
				
				serviceClass = table.className + this.serviceSuffix;
				modelClass = table.className + this.modelSuffix;
				
				fw.clear();
				fw.add('package ' + this.servicePackage).newLine();
				fw.add("{").newLine().indentForward();
				fw.add("import org.aerialframework.rpc.AbstractService;").newLine(2);
				fw.add("import "+ this.modelPackage +"."+ modelClass +";").newLine();
				fw.add("import "+ this.bootstrapPackage +".Aerial;").newLine(2);
				fw.add("public class "+ serviceClass +" extends AbstractService").newLine();
				fw.add("{").newLine().indentForward();
				fw.add("public function "+ serviceClass +"()").newLine();
				fw.add("{").newLine().indentForward();
				fw.add('super("'+serviceClass+'", Aerial, '+ modelClass +');').newLine().indentBack();
				fw.add("}").newLine().indentBack();
				fw.add("}").newLine().indentBack();
				fw.add("}").newLine();
				
				notify(this.servicePackage, table.className + serviceSuffix + ".as", fw.stream);
			}
		}
	}
}