package infinite.script.element;

class InfiScriptClass
{
    public var name:String;

    public var currentPackage:String;

    public var imports:Array<InfiScriptImport>;

    public var functions:Array<InfiScriptFuncion<Any>>;
    public var variables:Array<InfiScriptVariable<Any>>;

    public function new(name:String, ?currentPackage:String, ?imports:Array<InfiScriptImport>)
    {
        this.name = name;
        this.currentPackage ??= currentPackage ?? "";
        this.imports ??= imports ?? [];
    }
}
