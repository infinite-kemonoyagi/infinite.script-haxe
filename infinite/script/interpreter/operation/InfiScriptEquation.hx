package infinite.script.interpreter.operation;

import infinite.script.interpreter.token.InfiScriptAST;

class InfiScriptEquation extends InfiScriptOperationExpression
{
  public var leftHandSide:InfiScriptOperationExpression;
  public var rightHandSide:InfiScriptOperationExpression;

  public var op:InfiScriptAST;

  public var parent:Null<InfiScriptEquation> = null;

  public function new() super();
}
