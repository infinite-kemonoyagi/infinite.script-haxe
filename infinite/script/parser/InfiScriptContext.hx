package infinite.script.parser;

import haxe.ds.StringMap;
import infinite.script.element.InfiScriptElement;
import infinite.script.element.InfiScriptField;
import infinite.script.element.InfiScriptFunction;
import infinite.script.element.InfiScriptImport;
import infinite.script.element.InfiScriptVariable;
import infinite.script.interpreter.token.InfiScriptAST;
import infinite.script.interpreter.token.InfiScriptToken;
import infinite.script.util.InfiScriptUtils;

@:access(infinite.script.parser.InfiScriptParser)
class InfiScriptContext
{
  public var imports:Array<InfiScriptImport>;

  public var functions:StringMap<InfiScriptFunction>;
  public var variables:StringMap<InfiScriptVariable>;

  private var parser:InfiScriptParser;

  private var requestIndentifiers:StringMap<String>;
  private var requestValues:StringMap<InfiScriptElement>;

  public function new(parser:InfiScriptParser)
  {
    this.parser = parser;
    destroy();
  }

  public function destroy():Void
  {
    imports = [];
    functions = new StringMap();
    variables = new StringMap();

    requestIndentifiers = new StringMap();
    requestValues = new StringMap();
  }

  private function createField(?isLocal:Bool = false):InfiScriptField
  {
    // check if the field is a variable or a function
    var isVariable:Null<Bool> = null;

    var isVisible:Bool = false;
    var isStatic:Bool = false;
    var isFinal:Bool = false;

    do
    {
      final source:String = peek().source;

      switch source
      {
        case 'public' | 'private': isVisible = source == 'public';
        case 'variable' | 'function': isVariable = source == 'variable';
        case 'static': isStatic = true;
        case 'final': isFinal = true;
      }

      increasePosition();
    }
    while (isVariable == null || isAtTheEnd());

    return cast if (isVariable) createVariable(isVisible, isStatic, isFinal, false, false, isLocal);
    else createFunction(isVisible, isStatic, isFinal, isLocal);
  }

  private function createVariable(isVisible:Bool, isStatic:Bool, isFinal:Bool, ?isArgument:Bool = false,
    ?isOptional:Bool = false, ?isLocal:Bool = false):InfiScriptVariable
  {
    if (peek().type != InfiScriptAST.Identifier) throw 'variable should have a name';

    final name:String = peek().source;
    increasePosition();

    var type:String = "Dynamic";
    var initialValue:Null<Any> = null;

    if (peek().type == InfiScriptAST.Identifier)
    {
      type = peek().source;
      increasePosition();
    }

    final endArgument:Bool = isArgument && (peek().type == InfiScriptAST.Comma
      || peek().type == InfiScriptAST.RParen);
    final end:Bool = isArgument && peek().type == InfiScriptAST.Semicolon;

    if ((!end && !endArgument) && peek().type == InfiScriptAST.Equal)
    {
      if (type == "Dynamic") type = getTypeFromToken(next());
      initialValue = getValueFromToken(next());
      increasePosition((!isArgument) ? 2 : 1);
    }

    final variable:InfiScriptVariable = new InfiScriptVariable(name, type, initialValue);
    variable.setFieldData(isVisible, isStatic, isFinal);

    if (!isArgument && !isLocal) variables.set(name, variable);
    else if (isArgument)
    {
      if (isOptional == null) isOptional = initialValue != null;
      variable.setAsArgument(true, isOptional);
    }
    if (peek().type != InfiScriptAST.RParen) increasePosition();

    return variable;
  }

  private function createFunction(isVisible:Bool, isStatic:Bool, isFinal:Bool, ?isLocal:Bool = false):InfiScriptFunction
  {
    if (peek().type != InfiScriptAST.Identifier) throw 'function should have a name';

    final name:String = peek().source;
    increasePosition();

    var returns:String = "Dynamic";
    var arguments:StringMap<InfiScriptVariable> = new StringMap();

    if (peek().type == InfiScriptAST.LParen && next().type != InfiScriptAST.RParen)
    {
      increasePosition();
      do
      {
        arguments.set(peek().source, createVariable(false, false, false, true));
      }
      while (peek().type != InfiScriptAST.RParen);

      increasePosition();
    }

    if (peek().type == InfiScriptAST.Identifier)
    {
      returns = peek().source;
      increasePosition();
    }

    final end:InfiScriptAST = (peek().type == InfiScriptAST.LBrace) ? InfiScriptAST.RBrace : InfiScriptAST.Semicolon;
    if (peek().type == InfiScriptAST.LBrace) increasePosition();

    final bodyTokens:Array<InfiScriptToken> = [];
    var couldBeVoid:Bool = true;

    var bodyPosition:Int = 0;
    final storedLocalVariables:StringMap<InfiScriptVariable> = new StringMap();
    final storedLocalFunctions:StringMap<InfiScriptFunction> = new StringMap();

    do
    {
      if (peek().source == "return" && peek().type == InfiScriptAST.Keyword
        && next().type == InfiScriptAST.Semicolon && returns == "Dynamic") returns = "Void";
      else if (peek().source == "return" && peek().type == InfiScriptAST.Keyword && returns == "Dynamic")
      {
        returns = "Dynamic";
        couldBeVoid = false;
      }

      final token:InfiScriptToken = peek();

      if (token.type == InfiScriptAST.Keyword && InfiScriptUtils.fieldKeywords.contains(token.source))
      {
        final initialPosition:Int = parser.position;
        final initialBodyPosition:Int = bodyPosition;

        final field:InfiScriptField = createField(true);
        if (field is InfiScriptVariable) storedLocalVariables.set(field.name, cast field);
        else if (field is InfiScriptFunction) storedLocalFunctions.set(field.name, cast field);

        final differencePosition:Int = parser.position - initialPosition;
        final differenceBodyPosition:Int = bodyPosition - initialBodyPosition;

        parser.lexer.tokens.splice(initialPosition, differencePosition);
        parser.position -= differencePosition + 1;
      }

      bodyTokens.push(peek());
      increasePosition();
      ++bodyPosition;
    }
    while (peek().type != end);

    if (couldBeVoid && returns == "Dynamic") returns = "Void";

    for (variable in storedLocalVariables)
      trace('local variable | name: ${variable.name} | type: ${variable.type} | value: ${variable.value}');

    for (func in storedLocalFunctions)
      trace('local function | name: ${func.name} | arguments: ${func.arguments} | returns: ${func.type}');

    final func:InfiScriptFunction = new InfiScriptFunction(name, returns, arguments);
    func.localVariables = storedLocalVariables;
    func.localFunctions = storedLocalFunctions;
    func.tokens = bodyTokens;
    func.setFieldData(isVisible, isStatic, isFinal);
    if (!isLocal) functions.set(name, func);

    return func;
  }

  private function interpretTokensBody(tokens:Array<InfiScriptToken>,
    ?variables:StringMap<InfiScriptVariable>, ?functions:StringMap<InfiScriptFunction>)
  {
    var bodyPosition:Int = 0;

    if (variables == null) variables = this.variables;
    if (functions == null) functions = this.functions;

    final globalVariables:StringMap<InfiScriptVariable> = this.variables;
    final globalFunctions:StringMap<InfiScriptFunction> = this.functions;

    while (bodyPosition <= tokens.length - 1)
    {

    }
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
      case StringValue: parser.converter.tokenToString(token);
      case IntValue:    parser.converter.tokenToInt(token);
      case FloatValue:  parser.converter.tokenToFloat(token);
      case BoolValue:   parser.converter.tokenToBoolean(token);
      default:          throw 'Syntax error | ${token.source} is not a value or is not a compatible value';
    };
  }

  private function getTokensBody(?lastTokens:Array<InfiScriptAST>):Array<InfiScriptToken>
  {
    if (lastTokens == null) lastTokens = [InfiScriptAST.Semicolon];

    final body:Array<InfiScriptToken> = [];
    while (compareTypePeekAndNext(lastTokens[0], lastTokens[1]) && !isAtTheEnd())
    {
      body.push(peek());
      increasePosition();
    }

    return body;
  }

  private function compareTypePeekAndNext(a:InfiScriptAST, b:InfiScriptAST):Bool
    return peek().type == a && next().type == b;

  private inline function comparePeekAndNext(a:InfiScriptToken, b:InfiScriptToken):Bool
    return compareTypePeekAndNext(a.type, b.type);

  private function increasePosition(?value:Int = 1):Int return parser.increasePosition(value);

  private inline function isAtTheEnd():Bool return parser.isAtTheEnd();

  private inline function peek():Null<InfiScriptToken> return parser.peek();

  private inline function next():Null<InfiScriptToken> return parser.next();
}
