package infinite.script.element;

import haxe.ds.StringMap;
import infinite.script.interpreter.token.InfiScriptToken;

class InfiScriptFunction extends InfiScriptField
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
    public var type:String;

    /**
     * the function's code
     */
    public var tokens:Array<InfiScriptToken>;

    /**
     * the function's arguments as an array
     *
     * ```
     * function name(argument1 String, ?argument2 Int = 2) Void
     * {
     *  // code...
     * }
     * ```
     */
    public var argumentList:Null<Array<InfiScriptVariable>>;

    /**
     * the function's arguments as an map
     *
     * ```
     * function name(argument1 String, ?argument2 Int = 2) Void
     * {
     *  // code...
     * }
     * ```
     */
    public var arguments:Null<StringMap<InfiScriptVariable>>;

    public function new(name:String, type:String, ?arguments:StringMap<InfiScriptVariable>)
    {
        super(name);
        this.type = type;
        this.tokens = [];
        this.arguments ??= arguments;
        if (arguments != null)
        {
            argumentList = [];
            for (argument in arguments) argumentList.push(argument);
        }
    }

    public function call(?arguments:Array<Any>)
    {
        for (index => argument in argumentList)
        {
            final argToCopy:InfiScriptVariable = arguments[index];
            argument.value = argToCopy;
        }
    }
}