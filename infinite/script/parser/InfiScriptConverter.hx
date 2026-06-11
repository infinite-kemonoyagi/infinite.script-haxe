package infinite.script.parser;

import infinite.script.interpreter.token.InfiScriptAST;
import infinite.script.interpreter.token.InfiScriptToken;
import infinite.script.util.InfiScriptUtils;

@:nullSafety
class InfiScriptConverter
{
  public function new() {}

  public function tokenToString(token:InfiScriptToken):String
  {
    if (token.type != InfiScriptAST.StringValue && token.type != InfiScriptAST.IntValue
      && token.type != InfiScriptAST.FloatValue && token.type != InfiScriptAST.BoolValue)
    {
      throw 'value | ${token.source} | should be a string or a compatible value';
    }

    return token.source;
  }

  public function tokenToInt(token:InfiScriptToken):Int
  {
    if (token.type != InfiScriptAST.IntValue) throw 'value | ${token.source} | should be a int value';

    return Std.parseInt(token.source) ?? 0;
  }

  public function tokenToFloat(token:InfiScriptToken):Float
  {
    if (token.type != InfiScriptAST.IntValue && token.type != InfiScriptAST.FloatValue)
      throw 'value | ${token.source} | should be a int/float value';

    return Std.parseFloat(token.source) ?? 0.0;
  }

  public function tokenToBoolean(token:InfiScriptToken):Bool
  {
    if (token.type != InfiScriptAST.BoolValue && InfiScriptUtils.booleanValues.contains(token.source))
    {
      if (token.type != InfiScriptAST.BoolValue) throw 'value | ${token.source} | should be a boolean value';
      trace("WARNING | is recommended to do not use string value for booleans");
    }

    return token.source == "true" || token.source == "1";
  }
}
