/**
 * @file squirrel4doxygen_test.nut File for testing the doxygen parsing of valid Squirrel language constructs.
 */

/** Enum test: Doesn't end with a ';' which confuses doxygen if we don't handle it. */
enum Something {
	FirstValue,
	SecondValue
}


_global_private = 1;	///< Private don't use! (Will be shown in doxygen anyway currently.)
global_public = 1;		///< Public use

/** Class Test is a Squirrel class to test our doxygen filter. */
class Test extends AIController {
    distance_of_route = {};		///< public, should be visible
	_class_private_var = null;	///< private, don't use!
_private_start_of_line = true;	///< Another private that should be hidden!

	doxygen_private = -1;		///< @private Using doxygen command to make 1 class item private
	
	/** This is a private Enum that should not appear in public documentation. */
	enum _Private_Enum {
		Train,
		Car,
		Ship,
		Airplane
	}


	/** Construct class Test. */
    constructor()
    {
    }

    function dummy() { }
	
	/** This is for internal use only! */
	function _internal() {}
	
	/// @privatesection
	/** This section should stay private. We use the doxygen private section command. */
	function Private1() {}
	/** Second private function that should not be visible. */
	function Private2() {}
	function Third() {}
	
	/// @publicsection
	/** Part of a public section that should be visible with doxygen. */
	function ThisShouldBePublic() {}

}

class DotTest.Test extends Test
{
	/** Override default dummy. */
	function dummy(x, y) {}
	
	/** Class_Enum is an enum belonging to DotTest. */
	enum Class_Enum {
		One, Two, Three
	}
}

function DotTest.Test::dummy(x, y)
{
	return x * y;
}

/** Documentation for main dummy outside our Test class. */
function Test::dummy()
{
	return 0;
}

function Test::DeclareOutsideClass()
{
}

/** NewFunc does new things. */
function DotTest.Test::NewFunc()
{
	return -1;
}

function DotTest.Test::Whatever()
{
	enum Abc {
		Aa, Bb, Cc
	}
}

/** NonClassFunction does nothing. */
function NonClassFunction()
{
}

/** 
 * This is a private function. Don't use.
 * Will be shown in doxygen anyway currently. Hiding this would need more parsing.
 */
function _PrivateFunction()
{
}

/// @cond PRIVATE
/** This is a private function that should be hidden in doxygen.
 * It uses a doxygen conditional define section.
 */
function _HiddenPrivateFunction()
{
}
/// @endcond

/* The order in which class member functions are declared shouldn't matter. */
function Test::AnotherFunc()
{
	NonClassFunction();
}
/** This is a private function part of our Test class. */
function Test::_PrivateFuncDeclaredOutsideClass()
{
}