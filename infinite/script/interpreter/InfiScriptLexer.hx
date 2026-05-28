package infinite.script.interpreter;

import infinite.script.interpreter.token.InfiScriptAST;
import infinite.script.interpreter.token.InfiScriptToken;
import infinite.script.util.InfiScriptUtils;
import infinite.util.InfiUtils;

using StringTools;

class InfiScriptLexer
{
    /**
     * The loaded tokens for the script
     */
    public var tokens:Array<InfiScriptToken>;

    /**
     * The scripted code splitted for each character
     */
    public var source:Array<String> = [];

    private var position:Int = 0;
    private var distPosition:Int = 0;
    private var line:Int = 0;

    public function new()
    {
        tokens = [];
    }

    /**
     * load tokens from a scripted code
     * @param source the full code
     */
    public function loadFromSource(source:String)
    {
        if (tokens.length > 0) tokens = [];
        position = line = 0;

        this.source = source.split("");

        var isSimpleComment:Bool = false;

        while (!isAtTheEnd())
        {
            if (peek() == "\n") isSimpleComment = false;

            ignoreWhiteSpace();

            if (isAtTheEnd())
            {
                tokens.push(new InfiScriptToken(Eof, line, position, peek()));
                break;
            }

            if (peek() == "/" && next() == "/") isSimpleComment = true;

            if (isSimpleComment)
            {
                ++position;
                continue;
            }

            if (InfiUtils.alphabet.contains(peek()) || peek() == "_")
            {
                final identifier = getIndentifier(source);
                tokens.push(identifier);
                continue;
            }

            final isNegative:Bool = peek() == "-" && InfiUtils.numbers.contains(next());
            if (InfiUtils.numbers.contains(peek()) || isNegative)
            {
                final number = getNumber(source);
                tokens.push(number);
                continue;
            }

            if (peek() == "\"" || peek() == "\'")
            {
                final string = getString(source);
                tokens.push(string);
                ++position;
                continue;
            }

            final symbol = getSymbols();
            if (symbol != null)
            {
                tokens.push(symbol);
                position += distPosition;
                continue;
            }
        }
    }

    private function getIndentifier(source:String):InfiScriptToken
    {
        final start:Int = position;
        while (InfiUtils.alphabet.contains(peek()) || peek() == "_" && !isAtTheEnd()) ++position;
        final word:String = source.substr(start, position - start);
        if (InfiScriptUtils.keywords.contains(word))
            return new InfiScriptToken(Keyword, line, start, word);
        return new InfiScriptToken(Identifier, line, start, word);
    }

    private function getString(source:String):InfiScriptToken
    {
        final start:Int = position + 1;
        ++position;
        while (peek() != "\"" && peek() != "\'" && !isAtTheEnd()) ++position;
        return new InfiScriptToken(StringValue, line, start, source.substr(start, position - start));
    }

    private function getNumber(source:String):InfiScriptToken
    {
        final start:Int = position;
        final isNegative:Bool = peek() == "-" && InfiUtils.numbers.contains(next());
        if (isNegative) ++position;
        var type:InfiScriptAST = IntValue;
        while (InfiUtils.digits.contains(peek()) && !isAtTheEnd())
        {
            if (peek() == ".") type = FloatValue;
            ++position;
        }
        return new InfiScriptToken(type, line, start, source.substr(start, position - start));
    }

    private function getSymbols():InfiScriptToken
    {
        final character:String = peek();

        distPosition = 1;

        switch character
        {
            case "+":
                if (next() == "=")
                {
                    distPosition = 2;
                    return new InfiScriptToken(PlusEqual, line, position, peek() + next());
                }
                else if (next() == "+")
                {
                    distPosition = 2;
                    return new InfiScriptToken(Increase, line, position, peek() + next());
                }
                return new InfiScriptToken(Plus, line, position, peek());
            case "-":
                if (next() == "=")
                {
                    distPosition = 2;
                    return new InfiScriptToken(MinusEqual, line, position, peek() + next());
                }
                else if (next() == "-")
                {
                    distPosition = 2;
                    return new InfiScriptToken(Decrease, line, position, peek() + next());
                }
                return new InfiScriptToken(Minus, line, position, peek());
            case "*":
                if (next() == "=")
                {
                    distPosition = 2;
                    return new InfiScriptToken(MultEqual, line, position, peek() + next());
                }
                return new InfiScriptToken(Mult, line, position, peek());
            case "/":
                if (next() == "=")
                {
                    distPosition = 2;
                    return new InfiScriptToken(SlashEqual, line, position, peek() + next());
                }
                return new InfiScriptToken(Slash, line, position, peek());

            case "=":
                if (next() == "=")
                {
                    distPosition = 2;
                    return new InfiScriptToken(EqualComparation, line, position, peek() + next());
                }
                return new InfiScriptToken(Equal, line, position, peek());
            case "!":
                if (next() == "=")
                {
                    distPosition = 2;
                    return new InfiScriptToken(NoEqual, line, position, peek() + next());
                }
                return new InfiScriptToken(Negative, line, position, peek());
            case ">":
                if (next() == "=")
                {
                    distPosition = 2;
                    return new InfiScriptToken(GreaterEqual, line, position, peek() + next());
                }
                return new InfiScriptToken(Greater, line, position, peek());
            case "<":
                if (next() == "=")
                {
                    distPosition = 2;
                    return new InfiScriptToken(LessEqual, line, position, peek() + next());
                }
                return new InfiScriptToken(Less, line, position, peek());

            case ";": return new InfiScriptToken(Semicolon, line, position, peek());
            case ":": return new InfiScriptToken(Colon, line, position, peek());
            case "(": return new InfiScriptToken(LParen, line, position, peek());
            case ")": return new InfiScriptToken(RParen, line, position, peek());
            case "{": return new InfiScriptToken(LBrace, line, position, peek());
            case "}": return new InfiScriptToken(RBrace, line, position, peek());
            case ",": return new InfiScriptToken(Comma, line, position, peek());
            case ".": return new InfiScriptToken(Dot, line, position, peek());
        }

        return null;
    }

    private inline function ignoreWhiteSpace():Void
    {
        final character:String = peek();
        switch character
        {
            case ' ' | '\r' | '\t': ++position;
            case '\n':
                ++line;
                ++position;
            default: return;
        }
    }

    private inline function isAtTheEnd():Bool return position >= source.length;

    private inline function peek():String return (isAtTheEnd() ? "" : source[position]);
    private inline function next():String return (isAtTheEnd() ? "" : source[position + 1]);
}
