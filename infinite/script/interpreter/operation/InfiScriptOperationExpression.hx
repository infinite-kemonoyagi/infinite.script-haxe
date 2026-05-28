package infinite.script.interpreter.operation;

class InfiScriptOperationExpression
{
  public var value:Float;

  public function new(?value:Float)
  {
    this.value ??= value ?? 0.0;
  }

  public function get():Float return value;
}
