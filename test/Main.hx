package test;

import infinite.script.interpreter.InfiScriptLexer;

class Main
{
    public static function main():Void
    {
        final lexer:InfiScriptLexer = new InfiScriptLexer();
        lexer.loadFromSource("variable name = \"Hello, World!\"; \ntrace(name);");

        for (token in lexer.tokens)
        {
            trace('type: ${token.type}, line: ${token.line}, pos: ${token.position}, content: ${token.source}');
        }
    }
}
