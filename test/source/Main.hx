package;

import infinite.script.interpreter.InfiScriptLexer;
import infinite.script.parser.InfiScriptParser;
import sys.io.File;

class Main
{
    public static function main():Void
    {
        final lexer:InfiScriptLexer = new InfiScriptLexer();
        final parser:InfiScriptParser = new InfiScriptParser();

        trace("Basic operations code:");
        final code:String = File.getContent('./debug/Operations.infiscript');
        parser.runScriptedCode(code);

        trace("Variable code:");
        final code:String = File.getContent('./debug/Variable.infiscript');
        parser.runScriptedCode(code);
    }
}
