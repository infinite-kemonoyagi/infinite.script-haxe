package infinite.script.parser;

import haxe.ds.StringMap;
import infinite.script.element.InfiScriptElement;
import infinite.script.element.InfiScriptFunction;
import infinite.script.element.InfiScriptImport;
import infinite.script.element.InfiScriptVariable;
import infinite.script.interpreter.token.InfiScriptAST;
import infinite.script.interpreter.token.InfiScriptToken;

@:nullSafety
@:access(infinite.script.parser.InfiScriptParser)
class InfiScriptContext
{
  public var imports:Array<InfiScriptImport>;

  public var functions:Array<InfiScriptFunction>;
  public var variables:Array<InfiScriptVariable>;

  private var parser:InfiScriptParser;

  private var requestIndentifiers:StringMap<String>;
  private var requestValues:StringMap<InfiScriptElement>;

  public function new(parser:InfiScriptParser)
  {
    this.parser = parser;

    imports = [];
    functions = [];
    variables = [];

    requestIndentifiers = new StringMap();
    requestValues = new StringMap();
  }

  private function createField():Void
  {
    // TODO redo this
  }

  private function createVariable(isVisible:Bool, isStatic:Bool, isFinal:Bool):Void
  {
    // TODO redo this
  }

  private function createFunction(isVisible:Bool, isStatic:Bool, isFinal:Bool):Void
  {
    // TODO do this
  }

  private function getTypeFromToken(?token:InfiScriptToken):Null<String>
  {
    if (token == null) token = peek();
    return switch token.type
    {
      case NullValue:   "Dynamic";
      case StringValue: "String";
      case IntValue:    "Int";
      case FloatValue:  "Float";
      case BoolValue:   "Bool";
      case ArrayValue:  "Array";
      default:          throw 'Syntax error | ${token.source} is not a value';
    };
  }

  /**
   * get the value for a valuable token
   *
   * @return Any
   */
  private function getValueFromToken(?token:InfiScriptToken):Null<Any>
  {
    if (token == null) token = peek();

    return switch token.type
    {
      case NullValue:   null;
      case StringValue: token.source;
      case IntValue:    Std.parseInt(token.source);
      case FloatValue:  Std.parseFloat(token.source);
      case BoolValue:   token.source == "true" || token.source == "1";
      default:          throw 'Syntax error | ${token.source} is not a value or is not a compatible value';
    };
  }

  private inline function isAtTheEnd():Bool return parser.isAtTheEnd();

  private inline function peek():Null<InfiScriptToken> return parser.peek();

  private inline function next():Null<InfiScriptToken> return parser.next();
}
