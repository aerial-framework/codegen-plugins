package org.aerialframework.abstract
{
	public class OptionDescriptor
	{
		private var _name:String;
		private var _fieldName:String;
		private var _inputType:String;
		private var _property:String;
		private var _propertyCallback:Function;

		public static const TEXT_FIELD:String = "textField";
		public static const CHECKBOX_FIELD:String = "checkboxField";

		public function OptionDescriptor(name:String, fieldName:String, inputType:String, property:String, propertyFunction:Function=null)
		{
			this.name = name;
			this.fieldName = fieldName;
			this.inputType = inputType;
			this.property = property;
			this.propertyCallback = propertyFunction;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get fieldName():String
		{
			return _fieldName;
		}

		public function set fieldName(value:String):void
		{
			_fieldName = value;
		}

		public function get inputType():String
		{
			return _inputType;
		}

		public function set inputType(value:String):void
		{
			_inputType = value;
		}

		public function get property():String
		{
			return _property;
		}

		public function set property(value:String):void
		{
			_property = value;
		}

		public function get propertyCallback():Function
		{
			return _propertyCallback;
		}

		public function set propertyCallback(value:Function):void
		{
			_propertyCallback = value;
		}
	}
}
