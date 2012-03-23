package org.aerialframework.php
{
	import com.mysql.workbench.Inflector;
	import com.mysql.workbench.model.Table;

	import org.aerialframework.abstract.AbstractPlugin;
	import org.aerialframework.abstract.GeneratedFile;
	import org.aerialframework.abstract.OptionDescriptor;

	public class Service extends AbstractPlugin
	{
		public static const PACKAGE:String = "package";
		public static const TABLES:String = "tables";
		public static const SUFFIX:String = "suffix";
		public static const RESTFUL_ACCESS:String = "restfulAccess";

		private var servicesPackage:String;
		private var tables:Array;
		private var suffix:String;
		private var restfulAccess:Boolean;

		override public function initialize():*
		{
			servicesPackage = options.hasOwnProperty(PACKAGE) ? options[PACKAGE] : "org.aerialframework.service";
			tables = options.hasOwnProperty(TABLES) ? options[TABLES] : null;
			suffix = options.hasOwnProperty(SUFFIX) ? options[SUFFIX] : "Service";
			restfulAccess = options.hasOwnProperty(RESTFUL_ACCESS) ? options[RESTFUL_ACCESS] : true;
		}

		override public function get fileType():*
		{
			return "Aerial Service";
		}

		override public function get language():*
		{
			return "PHP";
		}

		override public function get exposedOptions():*
		{
			return [
				new OptionDescriptor("Package", PACKAGE, OptionDescriptor.TEXT_FIELD, "text"),
				new OptionDescriptor("Suffix", SUFFIX, OptionDescriptor.TEXT_FIELD, "text"),
				new OptionDescriptor("RESTful Access", RESTFUL_ACCESS, OptionDescriptor.CHECKBOX_FIELD, "selected")
			];
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
				fw.indentForward().add('public $modelName = "' + table.className + '";').newLine();

				if(restfulAccess)
					generateRestfulAccess(table);

				fw.indentBack().add('}').newLine();
				fw.indentBack().newLine(2);

				files.push(new GeneratedFile(this.fileType, this.servicesPackage, table.className + suffix + ".php", fw.stream));
			}

			return files;
		}

		private function generateRestfulAccess(table:Table):void
		{
			fw.indentBack().newLine(1).indentForward();

			// override AbstractService's functions so that RESTful access by annotations can be added
			// for each method
			var methods:Array = ["save", "update", "insert", "drop", "count"];

			for each(var method:String in methods)
			{
				var serviceName:String = Inflector.underscore(table.className).replace(/_/g, "-");
				var signature:String = getOverrideSignature(method);
				var superCall:String = getSuperCall(method);
				var httpVerb:String = getHTTPVerb(method);

				fw.add("/**").newLine();
				fw.add(" * @route\t\t\t/" + serviceName + "/" + method).newLine();
				fw.add(" * @routeMethods\t\t" + httpVerb).newLine();
				fw.add(" */").newLine();
				
				fw.add(signature).newLine();
				fw.add("{").newLine();
				fw.indentForward().add(superCall).newLine();
				fw.indentBack().add("}").newLine();

				fw.newLine(2);
			}
		}

		private function getOverrideSignature(method:String):String
		{
			switch(method)
			{
				case "save":
					return "public function save($object, $returnCompleteObject = false, $mapToModel = true)";
				case "update":
					return "public function update($object, $returnCompleteObject = false, $mapToModel = true)";
				case "insert":
					return "public function insert($object, $returnCompleteObject = false, $mapToModel = true)";
				case "drop":
					return "public function drop($object, $mapToModel = true)";
				case "count":
					return "public function count()";
			}

			return null;
		}

		private function getSuperCall(method:String):String
		{
			switch(method)
			{
				case "save":
					return "parent::save($object, $returnCompleteObject, $mapToModel);";
				case "update":
					return "parent::update($object, $returnCompleteObject, $mapToModel);";
				case "insert":
					return "parent::insert($object, $returnCompleteObject, $mapToModel);";
				case "drop":
					return "parent::drop($object, $mapToModel);";
				case "count":
					return "parent::count();";
			}

			return null;
		}

		private function getHTTPVerb(method:String):String
		{
			switch(method)
			{
				case "save":
					return "POST";
				case "update":
					return "POST";
				case "insert":
					return "POST";
				case "drop":
					return "POST";
				case "count":
					return "GET";
			}

			return null;
		}
	}
}