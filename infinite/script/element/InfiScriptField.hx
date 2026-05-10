package infinite.script.element;

class InfiScriptField
{
    public var name:String;

    /**
     * is the field public?
     */
    public var isVisible:Bool;
    /**
     * is the field static (if it's for the class itself and not for the object)?
     */
    public var isStatic:Bool;
    /**
     * is the field able to be modified after its declarations?
     */
    public var isFinal:Bool;

    public function new(name:String)
    {
        this.name = name;
        isVisible = false;
        isStatic = false;
        isFinal = false;
    }
}
