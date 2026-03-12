package infiscript.elements;

@:nullSafety
class InfiVariable<T:Any> extends InfiField
{
    public var value:T;

    public var getter:Null<()->T> = null;
    public var setter:Null<(value:T)->T> = null;

    public function new(name:String, defaultValue:T)
    {
        super(name);

        if (name == null) throw 'Error! | a variable name can\'t be null';
        this.name = name;
        this.value = defaultValue;
    }
}
