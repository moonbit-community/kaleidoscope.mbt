///|
// Kaleidoscope driver CLI.
//
//   moon run --target native main -- examples/fibonacci.kl          # LLVM IR
//   moon run --target native main --run -- examples/fibonacci.kl    # LLJIT
//   echo 'def add(x y) x + y; add(20, 22);' | moon run --target native main -- --run
//
// Pipeline: lexer (MoonBit `lexscan`) -> parser (moonyacc LR parser) ->
// LLVM IR (llvm.mbt) -> textual IR or in-process LLJIT execution.

///|
/// A unified driver-level error carrying a human readable message.
suberror DriverError {
  Message(String)
}

///|
struct Config {
  input : String
  run : Bool
}

///|
fn config_from_matches(matches : @argparse.Matches) -> Config raise {
  match matches {
    {
      values: { "input"? : Some([input, ..]), .. },
      flags: { "run"? : Some(_), .. },
      ..
    } => { input, run: true, }
    {
      values: { "input"? : Some([input, ..]), .. },
      flags: { "run"? : None, .. },
      ..
    } => { input, run: false, }
    _ => fail("missing parsed argument: input")
  }
}

///|
fn line_col(source : String, offset : Int) -> (Int, Int) {
  let mut line = 1
  let mut column = 1
  let end = if offset < 0 {
    0
  } else if offset > source.length() {
    source.length()
  } else {
    offset
  }
  for index in 0..<end {
    if source[index] == '\n' {
      line += 1
      column = 1
    } else {
      column += 1
    }
  }
  (line, column)
}

///|
fn describe_position(source : String, offset : Int) -> String {
  let (line, column) = line_col(source, offset)
  "\{line}:\{column}"
}

///|
/// A short human-readable spelling of a token for diagnostics.
fn token_spelling(token : @parser.Token) -> String {
  match token {
    @parser.Token::NUMBER(value) => "number \{value}"
    @parser.Token::IDENT(name) => "identifier '\{name}'"
    @parser.Token::DEF => "keyword 'def'"
    @parser.Token::EXTERN => "keyword 'extern'"
    @parser.Token::IF => "keyword 'if'"
    @parser.Token::THEN => "keyword 'then'"
    @parser.Token::ELSE => "keyword 'else'"
    @parser.Token::FOR => "keyword 'for'"
    @parser.Token::IN => "keyword 'in'"
    @parser.Token::LPAREN => "'('"
    @parser.Token::RPAREN => "')'"
    @parser.Token::COMMA => "','"
    @parser.Token::SEMI => "';'"
    @parser.Token::EQUAL => "'='"
    @parser.Token::PLUS => "'+'"
    @parser.Token::MINUS => "'-'"
    @parser.Token::STAR => "'*'"
    @parser.Token::SLASH => "'/'"
    @parser.Token::LT => "'<'"
  }
}

///|
fn expected_spellings(expected : Array[@parser.TokenKind]) -> Array[String] {
  let out : Array[String] = []
  for kind in expected {
    out.push("\{kind}")
  }
  out
}

///|
/// Lexes and parses one source text into a program.
///
/// A source with no tokens at all (empty or only whitespace and comments)
/// yields an empty program: moonyacc's array input mode cannot start from an
/// empty token array.
fn lex_and_parse(source : String) -> Array[@parser.TopLevel] raise DriverError {
  let tokens = @lexer.tokenize(source) catch {
    @lexer.LexError::UnexpectedCharacter(offset) =>
      raise DriverError::Message(
        "lex error at \{describe_position(source, offset)}",
      )
  }
  if tokens.is_empty() {
    return []
  }
  @parser.parse_program(tokens) catch {
    @parser.ParseError::UnexpectedToken(token, (start, _), expected) =>
      raise DriverError::Message(
        "parse error at \{describe_position(source, start)}: " +
        "unexpected \{token_spelling(token)}" +
        (if expected.is_empty() {
          ""
        } else {
          ", expected one of: \{expected_spellings(expected).join(", ")}"
        }),
      )
    @parser.ParseError::UnexpectedEndOfInput(position, expected) =>
      raise DriverError::Message(
        "parse error at \{describe_position(source, position)}: " +
        "unexpected end of input" +
        (if expected.is_empty() {
          ""
        } else {
          ", expected one of: \{expected_spellings(expected).join(", ")}"
        }),
      )
  }
}

///|
fn codegen_message(error : @codegen.CodegenError) -> String {
  match error {
    @codegen.CodegenError::Backend(message) => "backend error: \{message}"
    @codegen.CodegenError::UnknownFunction(name) => "unknown function '\{name}'"
    @codegen.CodegenError::UnknownVariable(name) => "unknown variable '\{name}'"
    @codegen.CodegenError::WrongArity(name, declared, given) =>
      "function '\{name}' expects \{declared} argument(s) but was called " +
      "with \{given}"
    @codegen.CodegenError::DuplicateFunction(name) =>
      "function '\{name}' is defined more than once"
    @codegen.CodegenError::VerificationFailed(message) =>
      "verification failed: \{message}"
  }
}

///|
/// Compiles source to a verified LLVM module plus its program.
fn compile_to_module(
  source : String,
) -> (@IR.Module, Array[@parser.TopLevel]) raise DriverError {
  let program = lex_and_parse(source)
  let ir_module = @codegen.compile_program(program, module_name="kaleidoscope") catch {
    error => raise DriverError::Message(codegen_message(error))
  }
  (ir_module, program)
}

///|
/// Prints a `Double` the way a REPL would: integers without a decimal part.
fn format_double(value : Double) -> String {
  let integral : Int = value.to_int()
  let fraction = value - integral.to_double()
  if fraction.abs() < 1.0e-9 && value.abs() < 1.0e15 {
    "\{integral}"
  } else {
    "\{value}"
  }
}

///|
/// Submits the module to an LLJIT session and runs every anonymous top-level
/// expression in source order, printing each result.
fn run_program(
  ir_module : @IR.Module,
  program : Array[@parser.TopLevel],
) -> Unit raise DriverError {
  let jit = @JIT.LLJIT::host() catch {
    _ => raise DriverError::Message("cannot start the LLJIT session")
  }
  jit.addModule(ir_module) catch {
    _ => raise DriverError::Message("jit submit failed")
  }
  let symbols = @codegen.anonymous_symbols(program)
  for symbol in symbols {
    let address = jit.lookup(symbol) catch {
      _ =>
        raise DriverError::Message(
          "jit lookup of '\{symbol}' failed (is the symbol exported?)",
        )
    }
    let thunk : FuncRef[() -> Double] = address.unsafeToFuncRef() catch {
      _ =>
        raise DriverError::Message(
          "cannot convert JIT address of '\{symbol}' to a function",
        )
    }
    println(format_double(thunk()))
  }
  ignore(jit.close() catch { _ => () })
}

///|
/// Runs the `--run` and default (print IR) modes.
fn process(source : String, run : Bool) -> Unit raise DriverError {
  if run {
    let (ir_module, program) = compile_to_module(source)
    run_program(ir_module, program)
  } else {
    let (ir_module, _) = compile_to_module(source)
    println(ir_module.to_string())
  }
}

///|
async fn main {
  let config = @argparse.parse(
      Command(
        "kaleidoscope",
        about="A Kaleidoscope compiler demo: lexscan lexer, moonyacc parser, llvm.mbt backend.",
        flags=[
          FlagArg(
            "run",
            long="run",
            about="Execute top-level expressions via LLJIT instead of printing IR.",
          ),
        ],
        positionals=[
          PositionArg(
            "input",
            default_values=["-"],
            about="Kaleidoscope source file, or '-' for stdin.",
          ),
        ],
      ),
    )
    |> config_from_matches
  let source = try {
    if config.input == "-" {
      @stdio.stdin.read_all().text()
    } else {
      @fs.read_file(config.input).text()
    }
  } catch {
    error => {
      @stdio.stderr.write("error: cannot read '\{config.input}': \{error}\n")
      @sys.exit(1)
      panic()
    }
  }
  process(source, config.run) catch {
    DriverError::Message(message) => {
      @stdio.stderr.write("error: \{message}\n")
      @sys.exit(1)
    }
  }
}
