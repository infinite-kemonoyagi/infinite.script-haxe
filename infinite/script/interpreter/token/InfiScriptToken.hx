package infinite.script.interpreter.token;

class InfiScriptToken
{
    /**
     * token's type arcoding to the Abstract Structure Type enum list.
     */
    public var type:InfiScriptAST;

    /**
     * token's line from the scripted code
     */
    public var line:Int;

    /**
     * token's position in their line
     */
    public var position:Int;

    /**
     * token's text data
     */
    public var source:String;

    public function new(type:InfiScriptAST, line:Int, position:Int, source:String)
    {
        this.type = type;
        this.line = line;
        this.position = position;
        this.source = source;
    }
}