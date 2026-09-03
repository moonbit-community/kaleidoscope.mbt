///|
/// Errors reported while lowering a parsed Kaleidoscope program to LLVM IR.
pub suberror CodegenError {
  /// An error surfaced by the LLVM backend.
  Backend(String)
  /// A call to a function that has no prototype in the module.
  UnknownFunction(String)
  /// A reference to a variable that is not in scope.
  UnknownVariable(String)
  /// A call whose argument count does not match the function's prototype.
  WrongArity(String, Int, Int)
  /// A module-level duplicate: a function name is defined more than once.
  DuplicateFunction(String)
  /// The module failed LLVM verification.
  VerificationFailed(String)
} derive(Debug)

///|
/// Wraps any raising LLVM API call and maps its error onto `CodegenError`.
fn[T] backend(action : () -> T raise) -> T raise CodegenError {
  action() catch {
    error => raise CodegenError::Backend(error.to_string())
  }
}
