package infinite.script.interpreter.operation;

import infinite.script.interpreter.token.InfiScriptAST;

class InfiScriptOperationExpression
{
  public var value:Float;

  public var type:InfiScriptAST;

  public function new(?value:Float, ?type:InfiScriptAST)
  {
    this.type ??= type ?? InfiScriptAST.IntValue;
    this.value ??= value ?? 0.0;
  }

  public function get():Float return value;
}
