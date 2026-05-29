package infinite.script.parser;

import haxe.ds.StringMap;
import infinite.script.element.InfiScriptField;
import infinite.script.element.InfiScriptFunction;
import infinite.script.element.InfiScriptVariable;
import infinite.script.interpreter.InfiScriptLexer;
import infinite.script.interpreter.operation.InfiScriptOperation;
import infinite.script.interpreter.operation.InfiScriptOperationExpression;
import infinite.script.interpreter.token.InfiScriptAST;
import infinite.script.interpreter.token.InfiScriptToken;
import infinite.script.reserved.TraceFunction;
import infinite.script.util.InfiScriptUtils;

class InfiScriptParser
{
  public var lexer:InfiScriptLexer;

  public var position:Int;

  public function new(?lexer:InfiScriptLexer)
  {
    this.lexer ??= lexer ?? new InfiScriptLexer();
  }

  public function runScriptedCode(code:String, traceData:Bool = false):Void
  {
    position = 0;
    #if !debug traceData = false; #end

    if (traceData)
    {
      trace('parsing the next code:');
      final codeSplitted:Array<String> = code.split('\n');
      for (s in codeSplitted) trace('\t$s');
      trace("\n");
    }

    lexer.loadFromSource(code);
    if (traceData)
    {
      for (token in lexer.tokens) trace('token | type: ${token.type} | source: ${token.source}');
      trace("\n");
    }

    final variables:StringMap<InfiScriptVariable> = new StringMap();
    final functions:StringMap<InfiScriptFunction> = new StringMap();

    functions.set("trace", new TraceFunction());

    while(!isAtTheEnd())
    {
      if (peek().type == InfiScriptAST.Semicolon)
      {
        ++position;
        continue;
      }

      if (peek().type == InfiScriptAST.Keyword)
      {
        final field:InfiScriptField = createField();

        if (field is InfiScriptVariable)
        {
          final variable:InfiScriptVariable = cast field;
          variables.set(variable.name, variable);
          if (traceData)
          {
            trace("detected a variable\n");
            trace('variable | name: ${variable.name} | type: ${variable.type} | value: ${variable.value}');
          }
        }
      }

      final isAutoOp:Bool = peek().type == InfiScriptAST.Increase
          || peek().type == InfiScriptAST.Decrease;
      final nextIsAutoOp:Bool = next() != null && (next().type == InfiScriptAST.Increase
          || next().type == InfiScriptAST.Decrease);

      if (isAutoOp || nextIsAutoOp)
      {
        var variable:InfiScriptVariable = null;
        var type:InfiScriptAST = null;
        if (isAutoOp)
        {
          final nextToken:String = next().source;
          variable = variables.get(nextToken);
          type = peek().type;
        }
        else
        {
          variable = variables.get(peek().source);
          type = next().type;
        }

        if (type == Increase) variable.value = (variable.value : Int) + 1;
        if (type == Decrease) variable.value = (variable.value : Int) - 1;

        position += 2;
      }

      if (peek().type == InfiScriptAST.Identifier)
      {
        final name = peek().source;
        if (functions.exists(name))
        {
          final arguments:Array<Any> = getCalledFunctionsArgs(name, variables);
          functions.get(name).call(arguments);
        }
        if (variables.exists(name))
        {
          final variable:InfiScriptVariable = variables.get(name);

          if (next().type == InfiScriptAST.Equal)
          {
            position += 2;
            if (isNumberValue()) variable.value = cast getNumberValue(variables, variable.type, peek());
            else variable.value = cast getValue(peek());
          }
          else if (InfiScriptUtils.operatorsEqual.contains(next().source))
          {
            ++position;

            if (isNumberValue(next()))
            {
              final op = peek().source;
              ++position;
              final add:Float = cast getNumberValue(variables, variable.type);

              switch op
              {
                case '+=':
                  if (variable.type == "Int")
                    variable.value = (variable.value : Int) + Std.int(add);
                  else
                    variable.value = (variable.value : Float) + add;
                case '-=':
                  if (variable.type == "Int")
                    variable.value = (variable.value : Int) - Std.int(add);
                  else
                    variable.value = (variable.value : Float) - add;
                case '*=':
                  if (variable.type == "Int")
                    variable.value = (variable.value : Int) * Std.int(add);
                  else
                    variable.value = (variable.value : Float) * add;
                case '/=':
                  if (variable.type == "Int")
                    variable.value = (variable.value : Int) / Std.int(add);
                  else
                    variable.value = (variable.value : Float) / add;
              }
            }
            else if (next().type == StringValue && peek().type == PlusEqual)
            {
              variable.value = (variable.value : String) + (getValue() : String);
            }
          }
        }
      }

      ++position;
    }
  }

  private function createField():InfiScriptField
  {
    var isVisible:Bool = false;
    var isStatic:Bool = false;
    var isFinal:Bool = false;
    var isVariable:Null<Bool> = null;
    var name:String = "";
    do
    {
      final source:String = peek().source;
      switch source
      {
        case 'public' | 'private': isVisible = source == 'public';
        case 'static': isStatic = true;
        case 'final': isFinal = true;
        case 'variable' | 'function': isVariable = source ==  'variable';
      }
      ++position;
    } while (isVariable == null);
    if (isVariable)
    {
      if (peek().type != InfiScriptAST.Identifier) throw 'variable must have a name';
      name = peek().source;

      ++position;

      var type:String = "";
      var value:Null<Any> = null;

      if (peek().type == InfiScriptAST.Semicolon)
      {
        type = "Dynamic";
        value = null;
      }
      else if (peek().type == InfiScriptAST.Equal)
      {
        if (next().source != "new")
        {
          type = getDynamicType();
          value = getValue();
        }
      }
      else
      {
        type = peek().source;
        ++position;

        if (peek().type == InfiScriptAST.Equal)
        {
          if (next().source != "new") value = getValue();
        }
      }

      final variable:InfiScriptVariable = new InfiScriptVariable(
        name,
        type,
        value
      );
      return variable;
    }

    return null;
  }

  private function createOperation(variables:StringMap<InfiScriptVariable>, ?last:Array<InfiScriptAST>):InfiScriptOperation
  {
    final operation:InfiScriptOperation = new InfiScriptOperation(getTokensBody(last));
    operation.parse(variables);
    return operation;
  }

  private function getCalledFunctionsArgs(name:String, variables:StringMap<InfiScriptVariable>):Array<Any>
  {
    if (next().type != InfiScriptAST.LParen) throw 'Syntax error';

    position += 2;

    var arguments:Array<Any> = [];

    while (peek().type != InfiScriptAST.RParen)
    {
      if (peek().type == InfiScriptAST.Identifier)
      {
        if (!variables.exists(peek().source)) throw 'Syntax error';
        arguments.push(variables.get(peek().source).value);
      }
      else
      {
        if (isNumberValue()) arguments.push(getNumberValue(variables, true,
          [InfiScriptAST.RParen, InfiScriptAST.Semicolon], peek()));
        else arguments.push(getValue(peek()));
      }
      if (peek().type == InfiScriptAST.RParen) break;
      ++position;
    }

    return arguments;
  }

  private function getTokensBody(?last:Array<InfiScriptAST>):Array<InfiScriptToken>
  {
    if (last == null) last = [InfiScriptAST.Semicolon];
    final body:Array<InfiScriptToken> = [];
    while ((peek().type != last[0] && next().type != last[1]) && !isAtTheEnd())
    {
      body.push(peek());
      ++position;
    }
    return body;
  }

  private function getNumberValue(variables:StringMap<InfiScriptVariable>,
    ?type:String = "Int", ?isDynamic:Bool = false, ?last:Array<InfiScriptAST>, ?token:InfiScriptToken):Float
  {
    if (InfiScriptUtils.operatorsToken.contains(next().type))
    {
      final operation:InfiScriptOperation = createOperation(variables, last);
      final result:InfiScriptOperationExpression = operation.evaluate();
      if (result.type == FloatValue && type == "Int" && !isDynamic)
        throw "Error! value should be a Int value";
      else if (isDynamic) type = (result.type == IntValue) ? "Int" : "Float";
      return cast result.value;
    }
    return cast getValue(token);
  }

  private function isNumberValue(?token:InfiScriptToken):Bool
  {
    if (token == null) token = peek();
    return token.type == InfiScriptAST.IntValue || token.type == InfiScriptAST.FloatValue
      || token.type == InfiScriptAST.LParen;
  }

  private function getDynamicType():Null<String>
  {
    return switch next().type
    {
      case NullValue:   "Dynamic";
      case StringValue: "String";
      case IntValue:    "Int";
      case FloatValue:  "Float";
      case BoolValue:   "Bool";
      case ArrayValue:  "Array";
      default: throw 'Syntax error';
    };
  }
  private function getValue(?token:InfiScriptToken):Null<Any>
  {
    if (token == null) token = next();
    return switch token.type
    {
      case NullValue:   null;
      case StringValue: token.source;
      case IntValue:    Std.parseInt(token.source);
      case FloatValue:  Std.parseFloat(token.source);
      case BoolValue:   token.source == "true" || token.source == "1";
      case ArrayValue:  null; // nothing at the moment...
      default: throw 'Syntax error';
    };
  }

  private inline function isAtTheEnd():Bool return position >= lexer.tokens.length;

  private inline function peek():Null<InfiScriptToken>
    return (isAtTheEnd() ? null : lexer.tokens[position]);

  private inline function next():Null<InfiScriptToken>
    return (isAtTheEnd() ? null : lexer.tokens[position + 1]);
}
