package infinite.script.parser;

import infinite.script.element.InfiScriptField;
import infinite.script.element.InfiScriptVariable;
import infinite.script.interpreter.InfiScriptLexer;
import infinite.script.interpreter.token.InfiScriptAST;
import infinite.script.interpreter.token.InfiScriptToken;

class InfiScriptParser
{
    public var lexer:InfiScriptLexer;

    public var position:Int;

    public function new(?lexer:InfiScriptLexer)
    {
        this.lexer ??= lexer ?? new InfiScriptLexer();
    }

    public function runSimpleCode(code:String, traceData:Bool = false):Void
    {
        position = 0;
        #if !debug traceData = false; #end

        if (traceData) trace('parsing the next code: $code');

        lexer.loadFromSource(code);
        if (traceData)
        {
            for (token in lexer.tokens) trace('token | type: ${token.type} | source: ${token.source}');
            trace("\n");
        }

        final variables:Array<InfiScriptVariable> = [];

        while(!isAtTheEnd())
        {
            if (peek().type == InfiScriptAST.Keyword)
            {
                final field:InfiScriptField = createField();

                if (field is InfiScriptVariable)
                {
                    final variable:InfiScriptVariable = cast field;
                    variables.push(variable);
                    if (traceData)
                    {
                        trace("detected a variable\n");
                        trace('variable | name: ${variable.name} | type: ${variable.type} | value: ${variable.value}');
                    }
                }
            }

            ++position;
        }
    }

    private function createField():InfiScriptField
    {
        var isVisible:Bool = false;
        var isStatic:Bool = false;
        var isFinal:Bool = false;
        var isVariable:Null<Bool> = null;
        var name:String = "";
        do
        {
            final source:String = peek().source;
            switch source
            {
                case 'public' | 'private': isVisible = source == 'public';
                case 'static': isStatic = true;
                case 'final': isFinal = true;
                case 'variable' | 'function': isVariable = source ==  'variable';
            }
            ++position;
        } while (isVariable == null);
        if (isVariable)
        {
            if (peek().type != InfiScriptAST.Identifier) throw 'variable must have a name';
            name = peek().source;

            ++position;

            var type:String = "";
            var value:Null<Any> = null;

            if (peek().type == InfiScriptAST.Semicolon)
            {
                type = "Dynamic";
                value = null;
            }
            else if (peek().type == InfiScriptAST.Equal)
            {
                if (next().source != "new")
                {
                    type = getDynamicType();
                    value = next().source;
                }
            }
            else
            {
                type = peek().source;
                ++position;

                if (peek().type == InfiScriptAST.Equal)
                {
                    if (next().source != "new") value = getValue();
                }
            }

            final variable:InfiScriptVariable = new InfiScriptVariable(
                name,
                type,
                value
            );
            return variable;
        }

        return null;
    }

    private function getDynamicType():Null<String>
    {
        return switch next().type
        {
            case NullValue:   "Dynamic";
            case StringValue: "String";
            case IntValue:    "Int";
            case FloatValue:  "Float";
            case BoolValue:   "Bool";
            case ArrayValue:  "Array";
            default: throw 'Syntax error';
        };
    }
    private function getValue():Null<Any>
    {
        return switch next().type
        {
            case NullValue:   null;
            case StringValue: next().source;
            case IntValue:    Std.parseInt(next().source);
            case FloatValue:  Std.parseFloat(next().source);
            case BoolValue:   next().source == "true" || next().source == "1";
            case ArrayValue:  null; // nothing at the moment...
            default: throw 'Syntax error';
        };
    }

    private inline function isAtTheEnd():Bool return position >= lexer.tokens.length;

    private inline function peek():Null<InfiScriptToken>
        return (isAtTheEnd() ? null : lexer.tokens[position]);

    private inline function next():Null<InfiScriptToken>
        return (isAtTheEnd() ? null : lexer.tokens[position + 1]);
}
