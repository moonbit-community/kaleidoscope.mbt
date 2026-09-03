///|
// Kaleidoscope lexer.
//
// Tokenization is driven by MoonBit's `lexscan` language feature over an
// in-memory `@lexbuf.StringScanner`: every case is a start-anchored regex and
// the scanner commits its cursor to the end of the longest selected match, so
// one `lexscan` per token advances through the whole input.

///|
/// A lexical error reported while tokenizing a source text.
pub suberror LexError {
  /// No rule matched at UTF-16 offset `offset`.
  UnexpectedCharacter(Int)
} derive(Debug)

///|
/// Maps a matched identifier spelling onto a keyword token or an `IDENT`.
fn ident_token(text : StringView) -> @parser.Token {
  let spelling = text.to_owned()
  match spelling {
    "def" => @parser.Token::DEF
    "extern" => @parser.Token::EXTERN
    "if" => @parser.Token::IF
    "then" => @parser.Token::THEN
    "else" => @parser.Token::ELSE
    "for" => @parser.Token::FOR
    "in" => @parser.Token::IN
    _ => @parser.Token::IDENT(spelling)
  }
}

///|
/// Parses a matched number literal into a `Double`.
fn number_value(text : StringView) -> Double raise LexError {
  let parsed : Double = @string.from_str(text.to_owned()) catch {
    _ => raise LexError::UnexpectedCharacter(0)
  }
  parsed
}

///|
/// Wraps a parsed number literal into a `NUMBER` token.
fn number_token(text : StringView) -> @parser.Token raise LexError {
  @parser.Token::NUMBER(number_value(text))
}

///|
/// Tokenizes a whole Kaleidoscope source text.
///
/// Returns the token stream in source order. Each element carries the token
/// together with the half-open UTF-16 offset range `(start, end)` of its text,
/// which the LR parser uses as positions.
pub fn tokenize(
  source : String,
) -> Array[(@parser.Token, Int, Int)] raise LexError {
  let scanner = @lexbuf.StringScanner::{ data: source[:], cursor: 0, }
  let tokens : Array[(@parser.Token, Int, Int)] = []
  let length = source.length()
  while scanner.cursor < length {
    let start = scanner.cursor
    let token : @parser.Token? = lexscan scanner with longest {
      re"^[ \t\r\n]+" => None
      re"^#[^\n]*" => None
      re"^[0-9]+(\.[0-9]+)?" as number => Some(number_token(number))
      re"^[A-Za-z][A-Za-z0-9_]*" as word => Some(ident_token(word))
      re"^\(" => Some(@parser.Token::LPAREN)
      re"^\)" => Some(@parser.Token::RPAREN)
      re"^," => Some(@parser.Token::COMMA)
      re"^;" => Some(@parser.Token::SEMI)
      re"^=" => Some(@parser.Token::EQUAL)
      re"^\+" => Some(@parser.Token::PLUS)
      re"^-" => Some(@parser.Token::MINUS)
      re"^\*" => Some(@parser.Token::STAR)
      re"^/" => Some(@parser.Token::SLASH)
      re"^<" => Some(@parser.Token::LT)
      _ => raise LexError::UnexpectedCharacter(start)
    }
    match token {
      Some(tok) => tokens.push((tok, start, scanner.cursor))
      None => ()
    }
  }
  tokens
}
