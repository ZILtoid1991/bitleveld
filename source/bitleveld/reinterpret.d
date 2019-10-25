/*
 * bitleveld - reinterpret.d
 * by Laszlo Szeremi
 *
 * Copyright under Boost Software License.
 *
 * Contains functions that can be used to reinterpret data types and arrays between each other.
 */

module bitleveld.reinterpret;
/*
 * Note on reinterpretation of pointers:
 *
 * The functions allow to cast pointers, but accessing those pointers might lead to memory leakage issues when accessing
 * them. The same is true for other types.
 */
/**
 * Thrown on a reinterpretation error.
 */
public class ReinterpretException : Exception {
	@nogc @safe pure nothrow this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null)
    {
        super(msg, file, line, nextInChain);
    }

    @nogc @safe pure nothrow this(string msg, Throwable nextInChain, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line, nextInChain);
    }
}
/**
 * Safely casts one type of an array to another.
 */
T[] reinterpretCast (T, U)(ref U[] input) @trusted pure {
	T[] _reinterpretCast() @system pure {
		return cast(T[])(cast(void[])input);
	}
	if ((U.sizeof * input.length) % T.sizeof == 0) return _reinterpretCast();
	else throw new ReinterpretException("Cannot cast safely!");
}
/**
 * Safely casts one type of an array to a single instance of a type.
 */
T reinterpretGet (T, U)(ref U[] input) @trusted pure {
	T _reinterpretGet() @system pure {
		return (cast(T[])(cast(void[])input))[0];
	}
	if (U.sizeof * input.length == T.sizeof) return _reinterpretGet;
	else throw new ReinterpretException("Cannot cast safely!");
	
}
/**
 * Safely cast a type into an array type.
 */
T[] reinterpretAsArray (T, U)(U input) @trusted pure {
	T[] _reinterpretAsArray() @system pure {
		return (cast(T[])(cast(void[])[input]));
	}
	if (U.sizeof % T.sizeof == 0) return _reinterpretAsArray;
	else throw new ReinterpretException("Cannot cast safely!");
}
/**
 * Copies the content of a string array into a static char array
 */
void stringCpy(CR)(ref CR target, string input) {
	for(size_t i ; i < input.length ; i++){
		target[i] = input[i];
	}
}
unittest {
	
	align(1) struct TestStruct {
		ubyte val0;
		ubyte val1;
		ubyte val2;
	}
	TestStruct x = TestStruct(1,2,3);
	byte[] testArray = reinterpretAsArray!(byte)(x);
	reinterpretGet!TestStruct(testArray);
	reinterpretCast!ubyte(testArray);
}