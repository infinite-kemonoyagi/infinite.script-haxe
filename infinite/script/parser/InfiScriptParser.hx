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
    createGlobalFields();

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

  private function createGlobalFields():Void
  {
    context.functions.set("trace", new TraceFunction());

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
      final differencePosition:Int = position - initialPosition;
      lexer.tokens.splice(initialPosition, differencePosition + 1);
      position -= differencePosition;
    }
    position = 0;
  }

  private function increasePosition(?value:Int = 1):Int return position += value;

  private inline function isAtTheEnd():Bool return position >= lexer.tokens.length;

  private inline function peek():Null<InfiScriptToken> return (isAtTheEnd() ? null : lexer.tokens[position]);

  private inline function next():Null<InfiScriptToken> return (isAtTheEnd() ? null : lexer.tokens[position + 1]);
}
