package infinite.script.reserved;

import haxe.ds.StringMap;
import infinite.script.element.InfiScriptFunction;
import infinite.script.element.InfiScriptVariable;

class TraceFunction extends InfiScriptFunction
{
    public function new()
    {
        final arguments:StringMap<InfiScriptVariable> = [
            "value" => new InfiScriptVariable("value", "Dynamic", null)
        ];
        super("name", "Void", arguments);
    }

    public override function call(?arguments:Array<Any>)
    {
        super.call(arguments);
        trace(this.arguments.get("value").value);
    }
}
