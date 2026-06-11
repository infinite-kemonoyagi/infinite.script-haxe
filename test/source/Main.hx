package;

import infinite.script.parser.InfiScriptParser;
import sys.io.File;

class Main
{
    public static function main():Void
    {
        final parser:InfiScriptParser = new InfiScriptParser();

        trace("Basic operations code:");
        final code:String = File.getContent('./debug/Operations.infiscript');
        parser.runScriptedCode(code);

        trace("Variable code:");
        final code:String = File.getContent('./debug/Variable.infiscript');
        parser.runScriptedCode(code);

        trace("Function code:");
        final code:String = File.getContent('./debug/Function.infiscript');
        parser.runScriptedCode(code);
    }
}
