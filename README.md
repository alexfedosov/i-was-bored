# IWasBored

"I was bored" is a toy programming language which looks like Swift and written in Swift.
I started it because I was bored, but also to learn more about lexers, parsers, ASTs and all the stuff needed to write an interpreter.

Current state of IWB:

```js
// String concatenation
var str = "hello";
print(str + ", " + "world"); // --> hello, world

// Basic math
var expr = (3 + 3) * 3 / -4.5 * (12 - -3.234);
print(expr); // --> -60.936

// Variable shadowing
var redefineMe = 1234;
var redefineMe = "redefined";
print(redefineMe); // --> redefined

// Global and local scopes
var a = 12;
{
  var a = a * 3.14;
  {
    var a = "inner a";
    print(a); // --> inner a
  }
  print(a); // --> 37.68
}
print(a); // --> 12

// Equality checks
print(1 > 2); // --> false
print(1 >= 1); // --> true
print(1 < 5); // --> true
print(10 <= 5); // --> false
print(true == false); // --> false
print(false == false); // --> true
print(false == nil); // --> false
print(nil == nil); // --> true
print("0" == 0); // --> false
print("hello" == "hello"); // --> true
```
