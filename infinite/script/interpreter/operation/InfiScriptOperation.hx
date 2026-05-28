package infinite.script.interpreter.operation;

import haxe.ds.StringMap;
import infinite.script.element.InfiScriptVariable;
import infinite.script.interpreter.token.InfiScriptAST;
import infinite.script.interpreter.token.InfiScriptToken;
import infinite.script.util.InfiScriptUtils;

class InfiScriptOperation
{
	public var tokens:Array<InfiScriptToken>;

	private var position:Int = 0;

	public var equation:InfiScriptEquation;
	public var lastEquation:InfiScriptEquation;

	public var isFloat:Bool = false;

	private var variables:Null<StringMap<InfiScriptVariable>>;

	public function new(tokens:Array<InfiScriptToken>)
	{
		equation = new InfiScriptEquation();
		this.tokens = tokens;
	}

	public function parse(?variables:StringMap<InfiScriptVariable>)
	{
		this.variables ??= variables;

		position = 0;
		equation = cast eval();
	}

	public function eval(?minBindPower:Float = 0):InfiScriptOperationExpression
	{
		var leftHandSide:InfiScriptOperationExpression = getCurrentAtom();
		++position;

		while (true)
		{
			final op:Null<InfiScriptToken> = peekOperator();
			if (op == null) break;

			final operatorBindPower:Float = getBindPower(op);
			if (operatorBindPower < minBindPower) break;

			++position;

			final maxBindPower:Float = getBindPower(op, true);
			final rightHandSide:InfiScriptOperationExpression = eval(maxBindPower);

			final equation:InfiScriptEquation = new InfiScriptEquation();
			equation.op = op.type;
			equation.leftHandSide = leftHandSide;
			equation.rightHandSide = rightHandSide;
			leftHandSide = cast equation;
		}

		return leftHandSide;
	}

	public function evaluate(?expression:InfiScriptOperationExpression = null):InfiScriptOperationExpression
	{
		if (expression == null) expression = this.equation;
		if (!(expression is InfiScriptEquation)) return expression;

		final equation:InfiScriptEquation = cast expression;
		final a = evaluate(equation.leftHandSide).get();
		final b = evaluate(equation.rightHandSide).get();
		return getBasicOperation(a, b, equation.op);
	}

	private function getCurrentAtom():InfiScriptOperationExpression
	{
		return switch peek().type
		{
			case IntValue | FloatValue:
				if (peek().type == FloatValue) isFloat = true;
				new InfiScriptOperationExpression(Std.parseFloat(peek().source), isFloat ? InfiScriptAST.FloatValue : null);

			case Identifier:
				@:nullSafety(Off)
				final variable:InfiScriptVariable = variables.get(peek().source);
				if (variable.type == "Float") isFloat = true;
				new InfiScriptOperationVariable(variable, isFloat ? InfiScriptAST.FloatValue : null);

			case LParen:
				++position;
				final inner = eval();
				if (isAtTheEnd() || peek().type != RParen) throw 'Syntax error';
				inner;

			default: throw 'Syntax error';
		};
	}

	public function getBasicOperation(a:Float, b:Float, op:InfiScriptAST):InfiScriptOperationExpression
	{
		return switch op
		{
			case Plus: new InfiScriptOperationExpression(a + b);
			case Minus: new InfiScriptOperationExpression(a - b);
			case Mult: new InfiScriptOperationExpression(a * b);
			case Slash: new InfiScriptOperationExpression(a / b);
			default: throw 'Syntax error';
		}
	}

	private inline overload extern function getBindPower(value:InfiScriptAST, ?max:Bool = false):Float
	{
		return if (max)
			InfiScriptUtils.operatorsPower.get(value)[1];
		else
			InfiScriptUtils.operatorsPower.get(value)[0];
	}

	private inline overload extern function getBindPower(value:InfiScriptToken, ?max:Bool = false):Float
		return getBindPower(value.type, max);

	private function peekOperator():Null<InfiScriptToken>
	{
		final token:InfiScriptToken = peek();
		if (token == null) return null;
		return InfiScriptUtils.operatorsPower.exists(token.type) ? token : null;
	}

	private function isAtTheEnd():Bool return position >= tokens.length;

	private function peek():InfiScriptToken return (isAtTheEnd() ? null : tokens[position]);

	private function next():InfiScriptToken return (isAtTheEnd() ? null : tokens[position + 1]);
}
