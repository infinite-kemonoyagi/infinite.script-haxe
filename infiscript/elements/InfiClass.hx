package infiscript.elements;

@:nullSafety
class InfiClass
{
    public var name:String;

    public var pkg:String;

    public var imports:Array<InfiImport>;

    public var functions:Array<InfiFunction<Any>>;
    public var variables:Array<InfiVariable<Any>>;

    public function new(name:String, ?pkg:String, ?imports:Array<InfiImport>,
        ?functions:Array<InfiFunction<Any>>, ?variables:Array<InfiVariable<Any>>)
    {
        this.name = name;
        this.pkg ??= pkg ?? "";
        this.imports ??= imports ?? [];
        this.functions ??= functions ?? [];
        this.variables ??= variables ?? [];
    }
}
