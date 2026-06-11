package infinite.script.interpreter.operation;

import infinite.script.element.InfiScriptVariable;
import infinite.script.interpreter.token.InfiScriptAST;

class InfiScriptOperationVariable extends InfiScriptOperationExpression
{
  public var data:InfiScriptVariable;

  public function new(data:InfiScriptVariable, ?type:InfiScriptAST)
  {
    super(type);
    this.data = data;
  }

  public override function get():Float return cast data.value;
}
