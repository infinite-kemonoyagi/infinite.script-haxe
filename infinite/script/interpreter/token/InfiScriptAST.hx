package infinite.script.interpreter.token;

enum InfiScriptAST
{
    /**
     * variable, final, if, else... etc.
     */
    Keyword;
    /**
     * the field's name
     */
    Identifier;

    /**
     * null
     */
    NullValue;
    /**
     * "value"
     */
    StringValue;
    /**
     * 1
     */
    IntValue;
    /**
     * 1.5
     */
    FloatValue;
    /**
     * false
     */
    BoolValue;
    /**
     * [element1, element2]
     */
    ArrayValue;
    /**
     * new Object()
     */
    ObjectValue;

    /**
     * +
     */
    Plus;
    /**
     * +=
     */
    PlusEqual
    /**
     * ++
     */;
    Increase;
    /**
     * -
     */
    Minus;
    /**
     * -=
     */
    MinusEqual;
    /**
     * --
     */
    Decrease;
    /**
     * *
     */
    Mult;
    /**
     * *=
     */
    MultEqual;
    /**
     * /
     */
    Slash;
    /**
     * /=
     */
    SlashEqual;

    /**
     * >
     */
    Greater;
    /**
     * >=
     */
    GreaterEqual;
    /**
     * <
     */
    Less;
    /**
     * <=
     */
    LessEqual;

    /**
     * =
     */
    Equal;
    /**
     * !=
     */
    NoEqual;
    /**
     * ==
     */
    EqualComparation;
    /**
     * !
     */
    Negative;
    /**
     * ;
     */
    Semicolon;
    /**
     * ;
     */
    Colon;
    /**
     * (
     */
    LParen;
    /**
     * )
     */
    RParen;
    /**
     * {
     */
    LBrace;
    /**
     * }
     */
    RBrace;
    /**
     * ,
     */
    Comma;
    /**
     * .
     */
    Dot;

    /**
     * The end of the file
     */
    Eof;
}