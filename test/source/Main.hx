package;

import infinite.script.interpreter.InfiScriptLexer;
import infinite.script.interpreter.operation.InfiScriptOperation;
import infinite.script.parser.InfiScriptParser;

class Main
{
    public static function main():Void
    {
        final lexer:InfiScriptLexer = new InfiScriptLexer();
        final parser:InfiScriptParser = new InfiScriptParser();

        lexer.loadFromSource("(2 + 5) * 5 * 5");
        trace("(2 + 5) * 5 * 5");

        final operation:InfiScriptOperation = new InfiScriptOperation(lexer.tokens);
        operation.parse(null);
        trace('infinite script result: ${operation.evaluate().value}');
        trace('haxe result: ${(2 + 5) * 5 * 5}');

        /*trace("Basic operations code:");
        final code:String = File.getContent('./debug/Operations.infiscript');
        parser.runScriptedCode(code);

        trace("Variable code:");
        final code:String = File.getContent('./debug/Variable.infiscript');
        parser.runScriptedCode(code);*/
    }
}
