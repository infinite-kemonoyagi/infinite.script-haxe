package infiscript.elements;

@:nullSafety
class InfiFunction<T:Any> extends InfiField
{
    public var type:Class<T>;

    public var code:String;

    public var arguments:Array<InfiVariable<Any>>;

    public function new(name:String, arguments:Array<InfiVariable<Any>>, code:String)
    {
        super(name);

        this.arguments = arguments;
        this.code = code;
    }

    // does nothing for the moment
    public function run(...arguments:Array<Any>) {}
}
