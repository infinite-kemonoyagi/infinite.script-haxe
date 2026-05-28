package infinite.script.interpreter.operation;

import infinite.script.element.InfiScriptVariable;

class InfiScriptOperationVariable extends InfiScriptOperationExpression
{
  public var data:InfiScriptVariable;

  public function new(?name:String, data:InfiScriptVariable)
  {
    super();
    this.data = data;
  }

  public override function get():Float return cast data.value;
}
