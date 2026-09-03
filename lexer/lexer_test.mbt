///|
// Black-box tests for the lexer package.

///|
fn kind_tag(kind : @parser.TokenKind) -> String {
  match kind {
    @parser.TokenKind::TK_NUMBER => "NUMBER"
    @parser.TokenKind::TK_IDENT => "IDENT"
    @parser.TokenKind::TK_DEF => "DEF"
    @parser.TokenKind::TK_EXTERN => "EXTERN"
    @parser.TokenKind::TK_IF => "IF"
    @parser.TokenKind::TK_THEN => "THEN"
    @parser.TokenKind::TK_ELSE => "ELSE"
    @parser.TokenKind::TK_FOR => "FOR"
    @parser.TokenKind::TK_IN => "IN"
    @parser.TokenKind::TK_LPAREN => "LPAREN"
    @parser.TokenKind::TK_RPAREN => "RPAREN"
    @parser.TokenKind::TK_COMMA => "COMMA"
    @parser.TokenKind::TK_SEMI => "SEMI"
    @parser.TokenKind::TK_EQUAL => "EQUAL"
    @parser.TokenKind::TK_PLUS => "PLUS"
    @parser.TokenKind::TK_MINUS => "MINUS"
    @parser.TokenKind::TK_STAR => "STAR"
    @parser.TokenKind::TK_SLASH => "SLASH"
    @parser.TokenKind::TK_LT => "LT"
  }
}

///|
fn tags(tokens : Array[(@parser.Token, Int, Int)]) -> Array[String] {
  let out : Array[String] = []
  for item in tokens {
    out.push(kind_tag(item.0.kind()))
  }
  out
}

///|
test "numbers, operators and whitespace" {
  let tokens = @lexer.tokenize("1.5 + 2 * 3")
  assert_eq(tags(tokens), ["NUMBER", "PLUS", "NUMBER", "STAR", "NUMBER"])
  match tokens[0] {
    (@parser.Token::NUMBER(1.5), 0, 3) => ()
    _ => fail("unexpected first token")
  }
}

///|
test "keywords and identifiers" {
  let tokens = @lexer.tokenize("def extern if then else for in fibonacci")
  assert_eq(tags(tokens), [
    "DEF", "EXTERN", "IF", "THEN", "ELSE", "FOR", "IN", "IDENT",
  ])
}

///|
test "comments and newlines are skipped, offsets stay accurate" {
  // "# comment\n" is 10 UTF-16 code units; the first token starts at offset 10.
  let tokens = @lexer.tokenize("# comment\n2+2")
  assert_eq(tokens.length(), 3)
  match tokens {
    [
      (@parser.Token::NUMBER(2.0), 10, 11),
      (@parser.Token::PLUS, 11, 12),
      (_, _, _),
    ] => ()
    _ => fail("unexpected tokens")
  }
}

///|
test "identifier that merely starts with a keyword spelling is not a keyword" {
  let tokens = @lexer.tokenize("definer")
  assert_eq(tags(tokens), ["IDENT"])
}

///|
test "unexpected characters raise a lexical error" {
  let err : @lexer.LexError? = try {
    ignore(@lexer.tokenize("1 @ 2"))
    None
  } catch {
    e => Some(e)
  }
  match err {
    Some(@lexer.LexError::UnexpectedCharacter(2)) => ()
    _ => fail("expected UnexpectedCharacter at offset 2")
  }
}

///|
test "unary minus is tokenized as MINUS followed by a number" {
  let tokens = @lexer.tokenize("-3.5")
  assert_eq(tags(tokens), ["MINUS", "NUMBER"])
  match tokens[1] {
    (@parser.Token::NUMBER(v), _, _) => assert_true((v - 3.5).abs() < 1.0e-9)
    _ => fail("expected a number token")
  }
}
