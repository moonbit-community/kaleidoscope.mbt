///|
/// Kaleidoscope AST.
///
/// The semantic-value types referenced by the moonyacc grammar
/// (`kaleidoscope.mbty`) live in this file, in the same package as the
/// generated parser, so the grammar's embedded actions can name them
/// unqualified.
///
/// Every runtime value of the language is an IEEE-754 `Double`.

///|
/// Expression AST for the Kaleidoscope core language.
pub(all) enum Expr {
  /// A floating-point literal such as `1.5`.
  Number(Double)
  /// A reference to a variable, loop variable or function parameter.
  Variable(String)
  /// An unary operation. Only `"-"` is built in: `-x`.
  Unary(String, Expr)
  /// A binary operation on two sub-expressions, e.g. `a + b`.
  Binary(String, Expr, Expr)
  /// A function call: `name(arg1, arg2, ...)`.
  Call(String, Array[Expr])
  /// `if cond then then_branch else else_branch`.
  If(Expr, Expr, Expr)
  /// `for var = start, cond, step in body`.
  For(String, Expr, Expr, Expr, Expr)
} derive(Debug)

///|
/// A function prototype `name(param1 param2 ...)`.
pub(all) struct Prototype {
  name : String
  parameters : Array[String]
} derive(Debug)

///|
/// One whole-file top-level construct.
pub(all) enum TopLevel {
  /// `def prototype body` — a real function definition.
  FuncDef(Prototype, Expr)
  /// `extern prototype` — a declaration of a foreign function.
  Extern(Prototype)
  /// A bare expression, compiled to an anonymous zero-argument function.
  AnonExpr(Expr)
} derive(Debug)

//
// Small helpers invoked from the grammar's semantic actions. They are private
// to this package but visible from the generated parser file, which is
// compiled into the same package.
//

///|
fn empty_toplevels() -> Array[TopLevel] {
  []
}

///|
fn append_toplevel(items : Array[TopLevel], item : TopLevel) -> Array[TopLevel] {
  let out = [..items]
  out.push(item)
  out
}

///|
fn empty_strings() -> Array[String] {
  []
}

///|
fn one_string(s : String) -> Array[String] {
  [s]
}

///|
fn append_string(xs : Array[String], s : String) -> Array[String] {
  let out = [..xs]
  out.push(s)
  out
}

///|
fn empty_exprs() -> Array[Expr] {
  []
}

///|
fn one_expr(e : Expr) -> Array[Expr] {
  [e]
}

///|
fn append_expr(xs : Array[Expr], e : Expr) -> Array[Expr] {
  let out = [..xs]
  out.push(e)
  out
}
