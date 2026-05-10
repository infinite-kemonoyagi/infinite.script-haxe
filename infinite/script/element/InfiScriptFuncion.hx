package infinite.script.element;

import infinite.script.interpreter.token.InfiScriptToken;

@:generic
class InfiScriptFuncion<T:Any> extends InfiScriptField
{
    /**
     * function's type
     *
     * ```
     * function func1() Object
     * {
     *  // code...
     *  return new Object();
     * }
     *
     * function func2(argument String...) Void
     * {
     *  // only code and don't return nothing...
     * }
     * ```
     *
     * it's not necesary to include a explicit type, compiler can infer the type by the context
     *
     * ```
     * function name // it's not necesary to include the "()" if the function doesn't have arguments
     * {
     *  return new Object();
     * }
     * ```
     *
     * if the type can't be inferred, will be a Dynamic type
     */
    public var type(get, never):Class<T>;

    private var _type:Class<T>;

    /**
     * the function's code
     */
    public var tokens:Array<InfiScriptToken>;

    /**
     * the function's arguments
     *
     * ```
     * function name(argument1 String, ?argument2 Int = 2) Void
     * {
     *  // code...
     * }
     * ```
     */
    public var arguments:Null<Array<InfiScriptVariable<Any>>>;

    public function new(name:String, type:Class<T>, tokens:Array<InfiScriptToken>, ?arguments:Array<InfiScriptVariable<Any>>)
    {
        super(name);
        this._type = type;
        this.tokens = tokens;
        this.arguments ??= arguments;
    }

    private function get_type():Class<T> return _type;
}