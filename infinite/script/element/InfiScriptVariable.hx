package infinite.script.element;

@:generic
class InfiScriptVariable<T:Any> extends InfiScriptField
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
    public var type(get, never):Class<T>;

    /**
     * variable's value.
     *
     * if the variable is declared as final it can only assign a value in the declaration (or in the constructor)
     */
    public var value:Null<T>;

    /**
     * variable's getter method
     */
    public var getter:Null<Void->Null<T>>;
    /**
     * variable's setter method
     */
    public var setter:Null<T->Null<T>>;

    public function new(name:String, value:Null<T>, ?getter:Void->Null<T>, ?setter:T->Null<T>)
    {
        super(name);

        this.value ??= value;
        this.getter ??= getter ?? () -> value;
        this.setter ??= setter ?? (newValue:T) -> value = newValue;
    }

    private function get_type():Class<T> return Type.getClass(value);
}