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

        final variableCode:String = File.getContent('./debug/Variable.infiscript');

        parser.runSimpleCode(variableCode, true);
    }
}
