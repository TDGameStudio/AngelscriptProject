class Receiver
{
	int Value = 1;

	int Read() const
	{
		return Value;
	}
}

int Evaluate(Receiver Target, int Delta) external_implicit_this
{
	Value += Delta;
	if (Target.Value != Value)
		return -100;

	return Target.Value + Read();
}

int main(const array<string> args)
{
	Receiver Target = Receiver();
	const int Result = Evaluate(Target, 3);
	assert(Result == 8, "external receiver lookup should use declared parameter zero");
	assert(Target.Value == 4, "external receiver mutation should affect the passed object");
	return 0;
}
