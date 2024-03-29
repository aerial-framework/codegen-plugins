package org.aerialframework.flex
{
	import com.mysql.workbench.model.Table;

	import org.aerialframework.abstract.AbstractPlugin;
	import org.aerialframework.abstract.GeneratedFile;
	import org.aerialframework.abstract.OptionDescriptor;

	public class Service extends AbstractPlugin
	{
		public static const MODEL_PACKAGE:String = "modelPackage";
		public static const SERVICE_PACKAGE:String = "servicePackage";
		public static const TABLES:String = "tables";
		public static const MODEL_SUFFIX:String = "modelSuffix";
		public static const SERVICE_SUFFIX:String = "serviceSuffix";
		
		private var modelPackage:String;
		private var servicePackage:String;
		private var tables:Array;
		private var modelSuffix:String;
		private var serviceSuffix:String;
		
		override public function initialize():*
		{
			modelPackage = options.hasOwnProperty(MODEL_PACKAGE) ? options[MODEL_PACKAGE] : "org.aerialframework.vo";
			servicePackage = options.hasOwnProperty(SERVICE_PACKAGE) ? options[SERVICE_PACKAGE] : "org.aerialframework.service";
			tables = options.hasOwnProperty(TABLES) ? options[TABLES] : null;
			modelSuffix = options.hasOwnProperty(MODEL_SUFFIX) ? options[MODEL_SUFFIX] : "VO";
			serviceSuffix = options.hasOwnProperty(SERVICE_SUFFIX) ? options[SERVICE_SUFFIX] : "Service";
		}
		
		override public function get fileType():*
		{
			return "Flex Service";
		}

		override public function get language():*
		{
			return "ActionScript 3.0";
		}

		override public function get exposedOptions():*
		{
			return [
				new OptionDescriptor("Model Package", MODEL_PACKAGE, OptionDescriptor.TEXT_FIELD, "text"),
				new OptionDescriptor("Model Suffix", MODEL_SUFFIX, OptionDescriptor.TEXT_FIELD, "text"),
				new OptionDescriptor("Service Package", SERVICE_PACKAGE, OptionDescriptor.TEXT_FIELD, "text"),
				new OptionDescriptor("Service Suffix", SERVICE_SUFFIX, OptionDescriptor.TEXT_FIELD, "text")
			];
		}
		
		override public function generate():*
		{
			return generateServices();
		}
		
		private function generateServices():Array
		{
			if(!servicePackage || !modelPackage)
				throw new Error("'servicePackage' or 'modelPackage' are not set.");	
			
			var table:Table;
			var serviceClass:String;
			var modelClass:String;
			
			var files:Array = [];
			
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
				fw.add("import "+ this.modelPackage +"."+ modelClass +";").newLine(2);
				fw.add("public class "+ serviceClass +" extends AbstractService").newLine();
				fw.add("{").newLine().indentForward();
				fw.add("public function "+ serviceClass +"()").newLine();
				fw.add("{").newLine().indentForward();
				fw.add('super("'+serviceClass+'", '+ modelClass +');').newLine().indentBack();
				fw.add("}").newLine().indentBack();
				fw.add("}").newLine().indentBack();
				fw.add("}").newLine();
				
				files.push(new GeneratedFile(this.fileType, this.servicePackage, table.className + serviceSuffix + ".as", fw.stream));
			}
			
			return files;
		}
	}
}