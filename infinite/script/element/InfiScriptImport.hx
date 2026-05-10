package infinite.script.element;

typedef InfiScriptImport =
{
    language:InfiScriptImportLanguage,
    value:String
}

enum abstract InfiScriptImportLanguage(String) from String to String
{
    public inline final HAXE:InfiScriptImportLanguage = "haxe";
    public inline final INFILANG:InfiScriptImportLanguage = "infilang";
}