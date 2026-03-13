package infiscript;

using StringTools;

@:nullSafety
class InfiScriptParser
{
    private final spaceReg:EReg = ~/\s+/g;

    public function new() {}

    public function runCode(code:String)
    {
        final codeCleanned:String = spaceReg.replace(code, " ");
        trace(codeCleanned);
    }
}
