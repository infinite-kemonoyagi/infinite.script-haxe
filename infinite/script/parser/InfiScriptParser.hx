package infinite.script.parser;

import infinite.script.interpreter.InfiScriptLexer;
import infinite.script.interpreter.token.InfiScriptAST;
import infinite.script.interpreter.token.InfiScriptToken;
import infinite.script.reserved.TraceFunction;
import infinite.script.util.InfiScriptUtils;

@:access(infinite.script.parser.InfiScriptContext)
class InfiScriptParser
{
  public var lexer:InfiScriptLexer;
  public var context:InfiScriptContext;
  public var converter:InfiScriptConverter;

  public var position:Int;

  public var positionsToIgnore:Array<Int>;

  public function new(?lexer:InfiScriptLexer, ?context:InfiScriptContext, ?converter:InfiScriptConverter)
  {
    this.lexer ??= lexer ?? new InfiScriptLexer();
    this.converter ??= converter ?? new InfiScriptConverter();
    this.context ??= context ?? new InfiScriptContext(this);
  }

  public function runScriptedCode(code:String, debugMode:Bool = false, ?skipTokensTrace:Bool = false):Void
  {
    if (position != 0) position = 0;
    #if !debug debugMode = false; #end

    if (debugMode)
    {
      trace('=========================');
      trace('parsing the next code...');

      final splittedCode:Array<String> = code.split('\n');
      for (line in splittedCode) trace('\t$line');

      trace('=========================');
    }

    lexer.loadFromSource(code);

    if (debugMode && !skipTokensTrace)
    {
      for (token in lexer.tokens) trace ('token | type: ${token.type} | source: ${token.source}');
      trace('=========================');
    }

    context.destroy(); // reset context
    createFields();

    if (debugMode)
    {
      trace ('variables');
      for (variable in context.variables)
        trace ('variable | name: ${variable.name} | type: ${variable.type} | value: ${variable.value}');

      trace('=========================');

      trace ('functions');
      for (func in context.functions)
        trace ('function | name: ${func.name} | arguments: ${func.argumentList} | returns: ${func.type}');

      trace('=========================');
    }
  }

  private function createFields():Void
  {
    context.functions.set("trace", new TraceFunction());

    positionsToIgnore = [];
    while (!isAtTheEnd())
    {
      final token:InfiScriptToken = peek();

      if (token.type != InfiScriptAST.Keyword && !InfiScriptUtils.fieldKeywords.contains(token.source))
      {
        ++position;
        continue;
      }

      final initialPosition:Int = position;
      context.createField();
      for (num in initialPosition...position) positionsToIgnore.push(num);

      ++position;
    }
    position = 0;
  }

  private function increasePosition(?value:Int = 1):Int
  {
    var skip:Int = 0;
    if (positionsToIgnore.contains(position + value))
    {
      skip = position + value + 1;
      do
      {
        ++skip;
      }
      while (positionsToIgnore.contains(position + value));
    }
    return position += value + skip;
  }

  private inline function isAtTheEnd():Bool return position >= lexer.tokens.length;

  private inline function peek():Null<InfiScriptToken> return (isAtTheEnd() ? null : lexer.tokens[position]);

  private inline function next():Null<InfiScriptToken> return (isAtTheEnd() ? null : lexer.tokens[position + 1]);
}
