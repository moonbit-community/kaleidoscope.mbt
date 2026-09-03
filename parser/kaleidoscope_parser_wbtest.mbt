///|
// White-box tests for the generated Kaleidoscope parser.
//
// They build token arrays by hand (as the lexer will) and check the parse
// tree structurally by evaluating the arithmetic subset of the AST.

///|
fn eval_arith(e : Expr) -> Double raise {
  match e {
    Expr::Number(n) => n
    Expr::Unary("-", x) => -eval_arith(x)
    Expr::Unary(op, _) => fail("unexpected unary operator \{op}")
    Expr::Binary("+", l, r) => eval_arith(l) + eval_arith(r)
    Expr::Binary("-", l, r) => eval_arith(l) - eval_arith(r)
    Expr::Binary("*", l, r) => eval_arith(l) * eval_arith(r)
    Expr::Binary("/", l, r) => eval_arith(l) / eval_arith(r)
    Expr::Binary(op, _, _) => fail("unexpected binary operator \{op}")
    _ => fail("not an arithmetic expression")
  }
}

///|
fn assert_close(actual : Double, expected : Double) -> Unit raise {
  assert_true((actual - expected).abs() < 1.0e-9)
}

///|
fn tokens_from(list : Array[Token]) -> Array[(Token, Int, Int)] {
  let out : Array[(Token, Int, Int)] = []
  let mut pos = 0
  for t in list {
    out.push((t, pos, pos + 1))
    pos += 1
  }
  // Every top-level construct is terminated by ';' (the grammar forbids
  // bare adjacency between constructs).
  out.push((SEMI, pos, pos + 1))
  out
}

///|
test "left associativity of minus" {
  let tokens = tokens_from([
    NUMBER(10.0),
    MINUS,
    NUMBER(2.0),
    MINUS,
    NUMBER(3.0),
  ])
  let program = parse_program(tokens)
  guard program is [TopLevel::AnonExpr(e)] else { fail("expected one expr") }
  assert_close(eval_arith(e), 5.0)
}

///|
test "precedence: plus binds looser than star" {
  let tokens = tokens_from([NUMBER(1.0), PLUS, NUMBER(2.0), STAR, NUMBER(3.0)])
  let program = parse_program(tokens)
  guard program is [TopLevel::AnonExpr(e)] else { fail("expected one expr") }
  assert_close(eval_arith(e), 7.0)
}

///|
test "precedence: unary minus tighter than plus" {
  let tokens = tokens_from([MINUS, NUMBER(1.0), PLUS, NUMBER(2.0)])
  let program = parse_program(tokens)
  guard program is [TopLevel::AnonExpr(e)] else { fail("expected one expr") }
  assert_close(eval_arith(e), 1.0)
}

///|
test "parentheses override precedence" {
  let tokens = tokens_from([
    LPAREN,
    NUMBER(1.0),
    PLUS,
    NUMBER(2.0),
    RPAREN,
    STAR,
    NUMBER(3.0),
  ])
  let program = parse_program(tokens)
  guard program is [TopLevel::AnonExpr(e)] else { fail("expected one expr") }
  assert_close(eval_arith(e), 9.0)
}

///|
test "definition with two parameters and a body" {
  let tokens = tokens_from([
    DEF,
    IDENT("sub"),
    LPAREN,
    IDENT("lhs"),
    IDENT("rhs"),
    RPAREN,
    IDENT("lhs"),
    MINUS,
    IDENT("rhs"),
  ])
  let program = parse_program(tokens)
  match program {
    [TopLevel::FuncDef(proto, body)] => {
      assert_eq(proto.name, "sub")
      assert_eq(proto.parameters, ["lhs", "rhs"])
      match body {
        Expr::Binary("-", Expr::Variable("lhs"), Expr::Variable("rhs")) => ()
        _ => fail("unexpected body shape")
      }
    }
    _ => fail("expected a definition")
  }
}

///|
test "extern declaration" {
  let program = parse_program(
    tokens_from([EXTERN, IDENT("sin"), LPAREN, RPAREN]),
  )
  match program {
    [TopLevel::Extern(proto)] => {
      assert_eq(proto.name, "sin")
      assert_eq(proto.parameters, [])
    }
    _ => fail("expected an extern")
  }
}

///|
test "call with several arguments" {
  let tokens = tokens_from([
    IDENT("f"),
    LPAREN,
    NUMBER(1.0),
    COMMA,
    NUMBER(2.0),
    COMMA,
    NUMBER(3.0),
    RPAREN,
  ])
  let program = parse_program(tokens)
  match program {
    [TopLevel::AnonExpr(Expr::Call(name, args))] => {
      assert_eq(name, "f")
      assert_eq(args.length(), 3)
    }
    _ => fail("expected a call")
  }
}

///|
test "several top-level constructs are kept in order" {
  let tokens = tokens_from([
    DEF,
    IDENT("double"),
    LPAREN,
    IDENT("x"),
    RPAREN,
    IDENT("x"),
    PLUS,
    IDENT("x"),
    SEMI,
    NUMBER(1.0),
    SEMI,
    NUMBER(2.0),
  ])
  let program = parse_program(tokens)
  match program {
    [
      TopLevel::FuncDef(proto, _),
      TopLevel::AnonExpr(Expr::Number(1.0)),
      TopLevel::AnonExpr(Expr::Number(2.0)),
    ] => assert_eq(proto.name, "double")
    _ => fail("unexpected program shape")
  }
}
