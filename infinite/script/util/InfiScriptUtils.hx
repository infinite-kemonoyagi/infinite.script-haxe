package infinite.script.util;

import infinite.script.interpreter.token.InfiScriptAST;

class InfiScriptUtils
{
    public static var keywords:Array<String> = [
        "public", "private",
        "static", "inline", "final",
        "variable", "function",
        "if", "else", "for", "while", "do", "try", "catch", "switch", "case"
    ];

    public static var reservedFunctions:Array<String> = ["trace"];

    public static final operatorsEqual:Array<String> = [
        "+=",
        "-=",
        "*=",
        "/="
    ];

    public static final operatorsToken:Array<InfiScriptAST> = [
        InfiScriptAST.Plus,
        InfiScriptAST.Minus,
        InfiScriptAST.Mult,
        InfiScriptAST.Slash,
        InfiScriptAST.LParen,
        InfiScriptAST.RParen
    ];

    public static final operators:Array<String> = [
        "+",
        "-",
        "*",
        "/",
        "(",
        ")"
    ];

    public static final operatorsPower:Map<InfiScriptAST, Array<Float>> = [
        InfiScriptAST.Plus => [1.0, 1.1],
        InfiScriptAST.Minus => [1.0, 1.1],
        InfiScriptAST.Mult => [2.0, 2.1],
        InfiScriptAST.Slash => [2.0, 2.1],
    ];
}
