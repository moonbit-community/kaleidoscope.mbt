///|
/// Whole-program LLVM IR code generation for Kaleidoscope.
///
/// The generator follows the classic Kaleidoscope lowering: every value is a
/// `double`, function parameters live in entry-block allocas so `for` loops
/// can rebind their loop variable, `if/then/else` is lowered with a phi node,
/// and a `for` loop runs its body once before testing its condition.
///
/// The entry point is [`compile_program`](codegen.mbt); it returns a verified
/// LLVM `Module` that the driver can print or submit to a JIT.

///|
/// Owns the LLVM context, module, builder, and the current lexical variables
/// used during one whole-program code-generation pass.
pub struct CodegenContext {
  priv context : @IR.Context
  priv mod : @IR.Module
  priv builder : @IR.IRBuilder
  priv variables : Map[String, &@IR.Value]
}

///|
/// Creates an empty code-generation pass with no builder insertion point yet.
pub fn CodegenContext::new(
  module_name~ : String,
) -> CodegenContext raise CodegenError {
  let context = @IR.Context::new()
  let mod = backend(() => context.addModule(module_name))
  { context, mod, builder: context.createBuilder(), variables: Map([]), }
}

///|
/// Returns the module being built by this pass.
pub fn CodegenContext::getModule(self : CodegenContext) -> @IR.Module {
  self.mod
}

///|
/// The single runtime type of the language.
fn CodegenContext::doubleType(self : CodegenContext) -> @IR.DoubleType {
  self.context.getDoubleTy()
}

///|
/// Builds the LLVM function type `double(double, ..., double)`.
fn CodegenContext::doubleFunctionType(
  self : CodegenContext,
  arity : Int,
) -> @IR.FunctionType {
  let parameters : Array[&@IR.Type] = []
  for _ in 0..<arity {
    parameters.push(self.doubleType())
  }
  self.context.getFunctionType(self.doubleType(), parameters)
}

///|
/// A literal `double` constant.
fn CodegenContext::real(self : CodegenContext, value : Double) -> &@IR.Value {
  (self.context.getConstDouble(value) : &@IR.Value)
}

///|
/// Declares a function prototype in the module (without a body).
fn CodegenContext::declareFunction(
  self : CodegenContext,
  name : String,
  arity : Int,
) -> @IR.Function raise CodegenError {
  match self.mod.getFunction(name) {
    Some(function) => function
    None =>
      backend(() => self.mod.addFunction(self.doubleFunctionType(arity), name))
  }
}

///|
/// The function that owns the current builder insertion block.
fn CodegenContext::currentFunction(
  self : CodegenContext,
) -> @IR.Function raise CodegenError {
  guard self.builder.getInsertBlock() is Some(block) else {
    raise CodegenError::Backend("builder has no insertion block")
  }
  guard block.getParent() is Some(function) else {
    raise CodegenError::Backend("insertion block has no parent function")
  }
  function
}

///|
/// Allocates one `double` slot in the entry block of the current function.
fn CodegenContext::createEntryAlloca(
  self : CodegenContext,
  name : String,
) -> &@IR.Value raise CodegenError {
  let function = self.currentFunction()
  guard function.getBasicBlocks() is [entry, ..] else {
    raise CodegenError::Backend("function has no entry block")
  }
  let builder = self.context.createBuilder()
  match entry.getFirstInst() {
    Some(instruction) =>
      backend(() => builder.setInsertPointBefore(instruction))
    None => backend(() => builder.setInsertPoint(entry))
  }
  let storage = backend(() => builder.createAlloca(self.doubleType(), name~))
  (storage : &@IR.Value)
}

///|
/// Restores the previous binding of `name` after a scoped rebinding.
fn CodegenContext::restoreVariable(
  self : CodegenContext,
  name : String,
  previous : &@IR.Value?,
) -> Unit {
  match previous {
    Some(value) => self.variables.set(name, value)
    None => self.variables.remove(name)
  }
}

///|
/// Loads a variable's current value from its alloca slot.
fn CodegenContext::loadVariable(
  self : CodegenContext,
  name : String,
) -> &@IR.Value raise CodegenError {
  guard self.variables.get(name) is Some(slot) else {
    raise CodegenError::UnknownVariable(name)
  }
  backend(() => self.builder.createLoad(self.doubleType(), slot, name~))
}

///|
/// Lowers one expression to an LLVM value.
fn CodegenContext::codegenExpr(
  self : CodegenContext,
  expression : @parser.Expr,
) -> &@IR.Value raise CodegenError {
  match expression {
    @parser.Expr::Number(value) => self.real(value)
    @parser.Expr::Variable(name) => self.loadVariable(name)
    @parser.Expr::Unary("-", operand) =>
      backend(() => self.builder.createFNeg(self.codegenExpr(operand)))
    @parser.Expr::Unary(operator, _) =>
      raise CodegenError::Backend("unsupported unary operator: \{operator}")
    @parser.Expr::Binary(operator, lhs, rhs) =>
      self.codegenBinary(operator, lhs, rhs)
    @parser.Expr::Call(name, arguments) => self.codegenCall(name, arguments)
    @parser.Expr::If(condition, then, otherwise) =>
      self.codegenIf(condition, then, otherwise)
    @parser.Expr::For(loop_var, start, condition, step, body) =>
      self.codegenFor(loop_var, start, condition, step, body)
  }
}

///|
/// Lowers a built-in binary operator.
fn CodegenContext::codegenBinary(
  self : CodegenContext,
  operator : String,
  lhs : @parser.Expr,
  rhs : @parser.Expr,
) -> &@IR.Value raise CodegenError {
  let left = self.codegenExpr(lhs)
  let right = self.codegenExpr(rhs)
  match operator {
    "+" => backend(() => self.builder.createFAdd(left, right))
    "-" => backend(() => self.builder.createFSub(left, right))
    "*" => backend(() => self.builder.createFMul(left, right))
    "/" => backend(() => self.builder.createFDiv(left, right))
    "<" => {
      let comparison = backend(() => self.builder.createFCmpOLT(left, right))
      backend(() => {
        self.builder.createSelect(comparison, self.real(1.0), self.real(0.0))
      })
    }
    _ => raise CodegenError::Backend("unsupported binary operator: \{operator}")
  }
}

///|
/// Lowers a function call. The callee must have a declared prototype.
fn CodegenContext::codegenCall(
  self : CodegenContext,
  name : String,
  arguments : Array[@parser.Expr],
) -> &@IR.Value raise CodegenError {
  guard self.mod.getFunction(name) is Some(callee) else {
    raise CodegenError::UnknownFunction(name)
  }
  let declared = callee.getNumArgs()
  let given = arguments.length()
  guard declared == given else {
    raise CodegenError::WrongArity(name, declared, given)
  }
  let values : Array[&@IR.Value] = []
  for argument in arguments {
    values.push(self.codegenExpr(argument))
  }
  backend(() => self.builder.createCall(callee, values))
}

///|
/// Lowers `if cond then then_branch else else_branch` with a phi node.
fn CodegenContext::codegenIf(
  self : CodegenContext,
  condition : @parser.Expr,
  then_expr : @parser.Expr,
  else_expr : @parser.Expr,
) -> &@IR.Value raise CodegenError {
  let condition_value = self.codegenExpr(condition)
  let condition_cmp = backend(() => {
    self.builder.createFCmpONE(condition_value, self.real(0.0))
  })
  let function = self.currentFunction()
  let then_block = backend(() => function.addBasicBlock(name="then"))
  let else_block = backend(() => function.addBasicBlock(name="else"))
  let merge_block = backend(() => function.addBasicBlock(name="ifcont"))
  backend(() => self.builder.createCondBr(condition_cmp, then_block, else_block))
  |> ignore
  backend(() => self.builder.setInsertPoint(then_block))
  let then_value = self.codegenExpr(then_expr)
  // A branch expression may nest control flow (e.g. an `if` inside this
  // branch), so the value's block is wherever the branch code generation left
  // the builder — not necessarily `then_block` itself.
  guard self.builder.getInsertBlock() is Some(then_end) else {
    raise CodegenError::Backend("then branch has no insertion block")
  }
  backend(() => self.builder.createBr(merge_block)) |> ignore
  backend(() => self.builder.setInsertPoint(else_block))
  let else_value = self.codegenExpr(else_expr)
  guard self.builder.getInsertBlock() is Some(else_end) else {
    raise CodegenError::Backend("else branch has no insertion block")
  }
  backend(() => self.builder.createBr(merge_block)) |> ignore
  backend(() => self.builder.setInsertPoint(merge_block))
  let phi = backend(() => self.builder.createPHI(self.doubleType()))
  phi.addIncoming(then_value, then_end)
  phi.addIncoming(else_value, else_end)
  (phi : &@IR.Value)
}

///|
/// Lowers `for var = start, condition, step in body`.
///
/// The loop variable is rebound in an entry-block alloca, the body runs once
/// before the condition is tested, and the loop expression evaluates to `0.0`.
fn CodegenContext::codegenFor(
  self : CodegenContext,
  loop_var : String,
  start : @parser.Expr,
  condition : @parser.Expr,
  step : @parser.Expr,
  body : @parser.Expr,
) -> &@IR.Value raise CodegenError {
  let slot = self.createEntryAlloca(loop_var)
  let start_value = self.codegenExpr(start)
  backend(() => self.builder.createStore(start_value, slot)) |> ignore
  let function = self.currentFunction()
  let loop_block = backend(() => function.addBasicBlock(name="loop"))
  let after_block = backend(() => function.addBasicBlock(name="afterloop"))
  backend(() => self.builder.createBr(loop_block)) |> ignore
  backend(() => self.builder.setInsertPoint(loop_block))
  let previous = self.variables.get(loop_var)
  self.variables.set(loop_var, slot)
  ignore(self.codegenExpr(body))
  let current = backend(() => {
    self.builder.createLoad(self.doubleType(), slot, name=loop_var)
  })
  let step_value = self.codegenExpr(step)
  let next = backend(() => self.builder.createFAdd(current, step_value))
  backend(() => self.builder.createStore(next, slot)) |> ignore
  let condition_value = self.codegenExpr(condition)
  let condition_cmp = backend(() => {
    self.builder.createFCmpONE(condition_value, self.real(0.0))
  })
  backend(() => {
    self.builder.createCondBr(condition_cmp, loop_block, after_block)
  })
  |> ignore
  backend(() => self.builder.setInsertPoint(after_block))
  self.restoreVariable(loop_var, previous)
  self.real(0.0)
}

///|
/// Lowers one `def` into a complete function with an entry block.
fn CodegenContext::codegenDefinition(
  self : CodegenContext,
  name : String,
  parameters : Array[String],
  body : @parser.Expr,
) -> Unit raise CodegenError {
  let function = match self.mod.getFunction(name) {
    Some(function) => function
    None => self.declareFunction(name, parameters.length())
  }
  let entry = backend(() => function.addBasicBlock(name="entry"))
  backend(() => self.builder.setInsertPoint(entry))
  // Parameters are stored into entry-block allocas so `for` can later rebind
  // a same-named variable inside the body.
  let slots : Array[&@IR.Value] = []
  for parameter in parameters {
    let slot = self.createEntryAlloca(parameter)
    slots.push(slot)
    self.variables.set(parameter, slot)
  }
  for index, parameter in parameters {
    guard function.getArg(index) is Some(argument) else {
      raise CodegenError::Backend(
        "function `\{name}` is missing parameter `\{parameter}`",
      )
    }
    // Name the argument so printed IR reads `%lhs` instead of `%0`.
    backend(() => argument.setName(parameter)) |> ignore
    ignore(backend(() => self.builder.createStore(argument, slots[index])))
  }
  let value = self.codegenExpr(body)
  backend(() => self.builder.createRet(value)) |> ignore
}

///|
/// Clears the lexical bindings left over from a finished function.
fn CodegenContext::clearVariables(self : CodegenContext) -> Unit {
  for name in self.variables.keys() {
    self.variables.remove(name)
  }
}

///|
/// Verifies the finished module.
fn CodegenContext::verify(self : CodegenContext) -> Unit raise CodegenError {
  self.mod.verify() catch {
    @IR.VerificationError::VerificationError(message) =>
      raise CodegenError::VerificationFailed(message)
  }
}

///|
/// Compiles a whole parsed program into one verified LLVM module.
///
/// All prototypes (`extern` and `def`) are declared up front so functions can
/// call each other regardless of textual order; bare expressions become
/// zero-argument functions named `__anon_expr0`, `__anon_expr1`, ... in
/// source order.
pub fn compile_program(
  program : Array[@parser.TopLevel],
  module_name~ : String,
) -> @IR.Module raise CodegenError {
  let operation = CodegenContext::new(module_name~)
  let declared : Map[String, Int] = Map([])
  let defined : Map[String, Bool] = Map([])
  // Phase 1: declare every prototype.
  for item in program {
    match item {
      @parser.TopLevel::FuncDef(prototype, _)
      | @parser.TopLevel::Extern(prototype) => {
        let name = prototype.name
        let arity = prototype.parameters.length()
        if defined.get(name).unwrap_or(false) {
          raise CodegenError::DuplicateFunction(name)
        }
        match declared.get(name) {
          Some(previous) =>
            if previous != arity {
              raise CodegenError::DuplicateFunction(name)
            }
          None => {
            declared.set(name, arity)
            ignore(operation.declareFunction(name, arity))
          }
        }
        match item {
          @parser.TopLevel::FuncDef(_, _) => defined.set(name, true)
          _ => ()
        }
      }
      _ => ()
    }
  }
  // Phase 2: generate bodies in source order.
  let mut anon_index = 0
  for item in program {
    match item {
      @parser.TopLevel::Extern(_) => ()
      @parser.TopLevel::FuncDef(prototype, body) => {
        operation.clearVariables()
        operation.codegenDefinition(prototype.name, prototype.parameters, body)
      }
      @parser.TopLevel::AnonExpr(expression) => {
        let symbol = "__anon_expr\{anon_index}"
        anon_index += 1
        ignore(operation.declareFunction(symbol, 0))
        operation.clearVariables()
        operation.codegenDefinition(symbol, [], expression)
      }
    }
  }
  operation.verify()
  operation.getModule()
}

///|
/// The symbol names of the anonymous expressions in a program, in source
/// order, matching the names produced by [`compile_program`](codegen.mbt).
pub fn anonymous_symbols(program : Array[@parser.TopLevel]) -> Array[String] {
  let out : Array[String] = []
  let mut anon_index = 0
  for item in program {
    match item {
      @parser.TopLevel::AnonExpr(_) => {
        out.push("__anon_expr\{anon_index}")
        anon_index += 1
      }
      _ => ()
    }
  }
  out
}
