package;

import infiscript.InfiScriptParser;

@:nullSafety
class Main
{
    @:nullSafety(Off)
    private static var parser:InfiScriptParser;

    public static function main():Void
    {
        parser = new InfiScriptParser();

        simpleTrace();
        usingVariables();
        usingFunctions();
    }

    private static function simpleTrace():Void
    {
        parser.runCode('trace(\"Hello, World!\");');
        parser.runCode('trace(\"I  HAVE  TOO  MANY  SPACES\");');
    }

    private static function usingVariables():Void
    {
        parser.runCode('variable name String = \"Infinite Kemonoyagi\";
        variable age Int = 16;

        trace(name);
        trace(age);
        ');
    }

    private static function usingFunctions():Void
    {
        parser.runCode('setup();

        function setup() Void
        {
            trace(countApples(2));
        }

        function countApples(num Int) String
        {
            return \'There are $$num apples\';
        }
        ');
    }
}
