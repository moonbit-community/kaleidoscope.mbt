///|
// Black-box tests for the codegen package. They compile ASTs straight to LLVM
// modules and assert on the textual IR the llvm.mbt library produces.
//
// Note that llvm.mbt's IR builder constant-folds arithmetic over literals, so
// the instruction-level assertions below feed at least one runtime value
// (a function parameter) through every operator they want to observe.

///|
fn number(value : Double) -> @parser.Expr {
  @parser.Expr::Number(value)
}

///|
fn variable(name : String) -> @parser.Expr {
  @parser.Expr::Variable(name)
}

///|
fn binary(op : String, lhs : @parser.Expr, rhs : @parser.Expr) -> @parser.Expr {
  @parser.Expr::Binary(op, lhs, rhs)
}

///|
fn def(
  name : String,
  parameters : Array[String],
  body : @parser.Expr,
) -> @parser.TopLevel {
  @parser.TopLevel::FuncDef(@parser.Prototype::{ name, parameters, }, body)
}

///|
test "anonymous expression becomes a zero-argument double function" {
  let ir_module = @codegen.compile_program(
    [@parser.TopLevel::AnonExpr(binary("+", number(1.0), number(2.0)))],
    module_name="arith",
  )
  let ir = ir_module.to_string()
  assert_true(ir.contains("define double @__anon_expr0"))
  assert_true(ir.contains("ret double"))
}

///|
test "a parameterized function emits real fadd instructions" {
  let body = binary("+", variable("x"), number(2.0))
  let ir_module = @codegen.compile_program(
    [def("inc", ["x"], body)],
    module_name="inc",
  )
  let ir = ir_module.to_string()
  assert_true(ir.contains("define double @inc("))
  assert_true(ir.contains("fadd double"))
  assert_true(ir.contains("ret double"))
}

///|
test "operator precedence survives into the IR: x + x * 3" {
  let body = binary("+", variable("x"), binary("*", variable("x"), number(3.0)))
  let ir_module = @codegen.compile_program(
    [def("polynomial", ["x"], body)],
    module_name="mul",
  )
  let ir = ir_module.to_string()
  assert_true(ir.contains("fmul double"))
  assert_true(ir.contains("fadd double"))
}

///|
test "comparison lowers to fcmp olt on a runtime value" {
  let body = binary("<", variable("x"), number(10.0))
  let ir_module = @codegen.compile_program(
    [def("less", ["x"], body)],
    module_name="cmp",
  )
  let ir = ir_module.to_string()
  assert_true(ir.contains("fcmp olt double"))
}

///|
test "definition stores parameters in allocas and returns" {
  let body = binary("-", variable("lhs"), variable("rhs"))
  let ir_module = @codegen.compile_program(
    [def("sub", ["lhs", "rhs"], body)],
    module_name="subdef",
  )
  let ir = ir_module.to_string()
  assert_true(ir.contains("define double @sub("))
  assert_true(ir.contains("double %lhs"))
  assert_true(ir.contains("alloca double"))
  assert_true(ir.contains("store double"))
  assert_true(ir.contains("ret double"))
}

///|
test "calls resolve against declared functions" {
  let add_body = binary("+", variable("lhs"), variable("rhs"))
  let call = @parser.Expr::Call("add", [variable("a"), number(4.0)])
  let program = [
    def("add", ["lhs", "rhs"], add_body),
    def("twice_plus_four", ["a"], binary("+", call, variable("a"))),
  ]
  let ir_module = @codegen.compile_program(program, module_name="calldef")
  let ir = ir_module.to_string()
  assert_true(ir.contains("define double @add"))
  assert_true(ir.contains("call double @add"))
}

///|
test "extern declarations produce a module-level declaration" {
  let extern_decl = @parser.TopLevel::Extern(@parser.Prototype::{
    name: "sin",
    parameters: ["x"],
  })
  let call = @parser.Expr::Call("sin", [variable("x")])
  let program = [extern_decl, def("sinc", ["x"], call)]
  let ir_module = @codegen.compile_program(program, module_name="externs")
  let ir = ir_module.to_string()
  assert_true(ir.contains("declare double @sin"))
  assert_true(ir.contains("call double @sin"))
}

///|
test "if/then/else lowers to branches and a phi" {
  let condition = binary("<", variable("x"), number(2.0))
  let expression = @parser.Expr::If(condition, variable("x"), number(20.0))
  let ir_module = @codegen.compile_program(
    [def("pick", ["x"], expression)],
    module_name="ifs",
  )
  let ir = ir_module.to_string()
  assert_true(ir.contains("phi double"))
  assert_true(ir.contains("br label"))
}

///|
test "for loop lowers to blocks, an alloca and a conditional branch" {
  let one = number(1.0)
  let sum_body = binary("+", variable("acc"), variable("i"))
  let expression = @parser.Expr::For(
    "i",
    one,
    binary("<", variable("i"), variable("limit")),
    one,
    sum_body,
  )
  let body = binary("+", variable("acc"), expression)
  let ir_module = @codegen.compile_program(
    [def("accumulate", ["acc", "limit"], body)],
    module_name="forl",
  )
  let ir = ir_module.to_string()
  assert_true(ir.contains("alloca double"))
  assert_true(ir.contains("loop:"))
  assert_true(ir.contains("afterloop:"))
  assert_true(ir.contains("fcmp one double"))
  assert_true(ir.contains("ret double"))
}

///|
test "empty program compiles to a module with no functions" {
  let ir_module = @codegen.compile_program([], module_name="empty")
  let ir = ir_module.to_string()
  assert_true(!ir.contains("define double"))
}

///|
test "nested if/then/else in a branch verifies and lowers to phis" {
  // Regression: an `if` whose branch contains another `if` used to emit a phi
  // whose incoming blocks did not match the actual control flow, so the
  // module failed LLVM verification.
  let inner = @parser.Expr::If(
    binary("<", variable("x"), number(1.0)),
    number(2.0),
    number(3.0),
  )
  let outer = @parser.Expr::If(variable("x"), inner, number(4.0))
  let ir_module = @codegen.compile_program(
    [def("nested", ["x"], outer)],
    module_name="nested",
  )
  let ir = ir_module.to_string()
  // compile_program already ran verification; confirm phis are present.
  let phi_count = [..ir.split("\n")]
    .filter(l => l.contains("phi double"))
    .length()
  assert_true(phi_count >= 2)
}

///|
test "if inside a for loop body verifies" {
  let condition = binary("<", variable("i"), number(3.0))
  let body = @parser.Expr::If(
    variable("i"),
    binary("+", variable("acc"), variable("i")),
    variable("acc"),
  )
  let for_expr = @parser.Expr::For(
    "i",
    number(1.0),
    condition,
    number(1.0),
    body,
  )
  let ir_module = @codegen.compile_program(
    [def("loopif", ["acc"], for_expr)],
    module_name="loopif",
  )
  let ir = ir_module.to_string()
  assert_true(ir.contains("phi double"))
  assert_true(ir.contains("loop:"))
  assert_true(ir.contains("afterloop:"))
}
