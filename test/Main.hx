package test;

import infinite.script.interpreter.InfiScriptLexer;
import infinite.script.parser.InfiScriptParser;

class Main
{
    public static function main():Void
    {
        final lexer:InfiScriptLexer = new InfiScriptLexer();
        final parser:InfiScriptParser = new InfiScriptParser();
        parser.runSimpleCode("variable name = \"Hello, World!\";");
    }
}
