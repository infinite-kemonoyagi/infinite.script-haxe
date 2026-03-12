package infiscript.elements;

@:nullSafety
class InfiField
{
    public var name:String;

    public var isVisible:Bool = false;
    public var isStatic:Bool = false;
    public var isInline:Bool = false;
    public var isFinal:Bool = false;

    public function new(name:String)
    {
        this.name = name;
    }
}
