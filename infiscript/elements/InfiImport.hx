package infiscript.elements;

typedef InfiImport =
{
    language:InfiImportLanguage,
    value:String
}

enum abstract InfiImportLanguage(String) from String to String
{
    public inline final HAXE:InfiImportLanguage = "haxe";
    public inline final INFISCRIPT:InfiImportLanguage = "infiscript";
}
