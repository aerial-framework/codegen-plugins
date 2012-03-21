package org.aerialframework.flex
{
	import com.betabong.xml.e4x.E4X;
	import com.mysql.workbench.model.Schema;

	import org.aerialframework.abstract.AbstractPlugin;

	public class Bob extends AbstractPlugin
	{
		public static const PACKAGE:String = "package";
		public static const TABLES:String = "tables";
		public static const SUFFIX:String = "suffix";
		
		private var modelsPackage:String;
		private var tables:Array;
		private var suffix:String;
		
		public function Bob()
		{
		}
		
		override public function initialize():*
		{
			modelsPackage = options.hasOwnProperty(PACKAGE) ? options[PACKAGE] : "org.aerialframework.vo";
			tables = options.hasOwnProperty(TABLES) ? options[TABLES] : null;
			suffix = options.hasOwnProperty(SUFFIX) ? options[SUFFIX] : "VO";
		}
		
		override protected function get fileType():*
		{
			return "flex-model";
		}
		
		override public function generate():*
		{
			return generateModels();
		}
		
		private function generateModels():Array
		{
			if(!modelsPackage || !suffix)
				throw new Error("'modelsPackage' or 'suffix' are not set.");
			
			var tableName:String = 'User';
			trace(E4X.evaluate(relationships, 'mn..table.(text() == "' + tableName + '").parent()').toXMLString());
			
			return [];
		}
	}
}