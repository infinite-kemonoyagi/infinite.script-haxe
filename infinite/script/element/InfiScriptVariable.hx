package infinite.script.element;

class InfiScriptVariable extends InfiScriptField
{
    /**
     * variable's type
     *
     * ```
     * variable name Object = new Object();
     * ```
     *
     * it's not necesary to include a explicit type, compiler can infer the type by the context
     *
     * ### Example 1
     *
     * ```
     * variable name = new Object();
     * ```
     *
     * ### Example 2 (this only works on local variables)
     *
     * ```
     * variable name;
     * name = new Object();
     * ```
     *
     * if the type can't be inferred, will be a Dynamic type
     */
    public var type:Class<Any>;

    /**
     * variable's value.
     *
     * if the variable is declared as final it can only assign a value in the declaration (or in the constructor)
     */
    public var value:Null<Any>;

    /**
     * variable's getter method
     */
    public var getter:Null<Void->Null<Any>>;
    /**
     * variable's setter method
     */
    public var setter:Null<Any->Null<Any>>;

    public function new(name:String, type:Null<Class<Any>>, value:Null<Any>, ?getter:Void->Null<Any>, ?setter:Any->Null<Any>)
    {
        super(name);

        this.value ??= value;
        this.getter ??= getter ?? () -> value;
        this.setter ??= setter ?? (newValue:Any) -> value = newValue;
    }
}