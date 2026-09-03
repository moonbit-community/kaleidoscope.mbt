
pub(all) enum Token {
  NUMBER(Double)
  IDENT(String)
  DEF
  EXTERN
  IF
  THEN
  ELSE
  FOR
  IN
  LPAREN
  RPAREN
  COMMA
  SEMI
  EQUAL
  PLUS
  MINUS
  STAR
  SLASH
  LT
} derive(Debug)

pub fn Token::kind(self : Token) -> TokenKind {
  match self {
    NUMBER(_) => TK_NUMBER
    IDENT(_) => TK_IDENT
    DEF => TK_DEF
    EXTERN => TK_EXTERN
    IF => TK_IF
    THEN => TK_THEN
    ELSE => TK_ELSE
    FOR => TK_FOR
    IN => TK_IN
    LPAREN => TK_LPAREN
    RPAREN => TK_RPAREN
    COMMA => TK_COMMA
    SEMI => TK_SEMI
    EQUAL => TK_EQUAL
    PLUS => TK_PLUS
    MINUS => TK_MINUS
    STAR => TK_STAR
    SLASH => TK_SLASH
    LT => TK_LT
  }
}

pub(all) enum TokenKind {
  TK_NUMBER
  TK_IDENT
  TK_DEF
  TK_EXTERN
  TK_IF
  TK_THEN
  TK_ELSE
  TK_FOR
  TK_IN
  TK_LPAREN
  TK_RPAREN
  TK_COMMA
  TK_SEMI
  TK_EQUAL
  TK_PLUS
  TK_MINUS
  TK_STAR
  TK_SLASH
  TK_LT
}

pub impl Show for TokenKind with fn output(self, logger) {
  logger.write_string(
    match self {
      TK_NUMBER => "NUMBER"
      TK_IDENT => "IDENT"
      TK_DEF => "\"def\""
      TK_EXTERN => "\"extern\""
      TK_IF => "\"if\""
      TK_THEN => "\"then\""
      TK_ELSE => "\"else\""
      TK_FOR => "\"for\""
      TK_IN => "\"in\""
      TK_LPAREN => "\"(\""
      TK_RPAREN => "\")\""
      TK_COMMA => "\",\""
      TK_SEMI => "\";\""
      TK_EQUAL => "\"=\""
      TK_PLUS => "\"+\""
      TK_MINUS => "\"-\""
      TK_STAR => "\"*\""
      TK_SLASH => "\"/\""
      TK_LT => "\"<\""
    }
  )
}

pub impl Debug for TokenKind with fn to_repr(self) {
    match self {
      TK_NUMBER => Repr("NUMBER")
      TK_IDENT => Repr("IDENT")
      TK_DEF => Repr("def")
      TK_EXTERN => Repr("extern")
      TK_IF => Repr("if")
      TK_THEN => Repr("then")
      TK_ELSE => Repr("else")
      TK_FOR => Repr("for")
      TK_IN => Repr("in")
      TK_LPAREN => Repr("(")
      TK_RPAREN => Repr(")")
      TK_COMMA => Repr(",")
      TK_SEMI => Repr(";")
      TK_EQUAL => Repr("=")
      TK_PLUS => Repr("+")
      TK_MINUS => Repr("-")
      TK_STAR => Repr("*")
      TK_SLASH => Repr("/")
      TK_LT => Repr("<")
    }
}

pub suberror ParseError {
  UnexpectedToken(Token, (Int, Int), Array[TokenKind])
  UnexpectedEndOfInput(Int, Array[TokenKind])
} derive(Debug)

type YYObj = Error

priv suberror YYObj_Void

priv suberror YYObj_Expr {
  YYObj_Expr(Expr)
}

priv suberror YYObj_Array_Expr_ {
  YYObj_Array_Expr_(Array[Expr])
}

priv suberror YYObj_Array_String_ {
  YYObj_Array_String_(Array[String])
}

priv suberror YYObj_Array_TopLevel_ {
  YYObj_Array_TopLevel_(Array[TopLevel])
}

priv suberror YYObj_Double {
  YYObj_Double(Double)
}

priv suberror YYObj_String {
  YYObj_String(String)
}

priv suberror YYObj_TopLevel {
  YYObj_TopLevel(TopLevel)
}

priv suberror YYObj_Prototype {
  YYObj_Prototype(Prototype)
}

type YYState = (YYSymbol) -> YYDecision

type YYAction = (Int, ArrayView[(YYObj, Int, Int)]) -> YYObj

priv enum YYDecision {
  Accept
  Shift(YYState)
  Reduce(Int, YYSymbol, YYAction)
  ReduceNoLookahead(Int, YYSymbol, YYAction)
  Error
}

priv enum YYSymbol {
  T_NUMBER
  T_IDENT
  T_DEF
  T_EXTERN
  T_IF
  T_THEN
  T_ELSE
  T_FOR
  T_IN
  T_LPAREN
  T_RPAREN
  T_COMMA
  T_SEMI
  T_EQUAL
  T_PLUS
  T_MINUS
  T_STAR
  T_SLASH
  T_LT
  NT_parse_program
  NT_program
  NT_topdef
  NT_prototype
  NT_params
  NT_param_list
  NT_expr
  NT_add_expr
  NT_mul_expr
  NT_unary_expr
  NT_primary
  NT_args
  NT_arg_list
  EOI
}

// Workaround for EOI unused warning
fn init {
  match (EOI : YYSymbol) {
    EOI => ()
    _ => ()
  }
}

// file:///./kaleidoscope.mbty
// 65|    program ";"     { $1 }
fn yy_action_0(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Array_TopLevel_(_dollar1)
  YYObj_Array_TopLevel_({();  _dollar1 })
}

// file:///./kaleidoscope.mbty
// 66|    program topdef  { append_toplevel($1, $2) }
fn yy_action_1(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Array_TopLevel_(_dollar1)
  guard! _args[1].0 is YYObj_TopLevel(_dollar2)
  YYObj_Array_TopLevel_({();  append_toplevel(_dollar1, _dollar2) })
}

// file:///./kaleidoscope.mbty
// 70|    "def" prototype expr ";"  { TopLevel::FuncDef($2, $3) }
fn yy_action_2(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[1].0 is YYObj_Prototype(_dollar2)
  guard! _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_TopLevel({();  TopLevel::FuncDef(_dollar2, _dollar3) })
}

// file:///./kaleidoscope.mbty
// 71|    "extern" prototype ";"    { TopLevel::Extern($2) }
fn yy_action_3(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[1].0 is YYObj_Prototype(_dollar2)
  YYObj_TopLevel({();  TopLevel::Extern(_dollar2) })
}

// file:///./kaleidoscope.mbty
// 76|    IDENT "(" params ")"    { Prototype::{ name: $1, parameters: $3 } }
fn yy_action_4(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_String(_dollar1)
  guard! _args[2].0 is YYObj_Array_String_(_dollar3)
  YYObj_Prototype({();  Prototype::{ name: _dollar1, parameters: _dollar3 } })
}

// file:///./kaleidoscope.mbty
// 86|    param_list IDENT        { append_string($1, $2) }
fn yy_action_5(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Array_String_(_dollar1)
  guard! _args[1].0 is YYObj_String(_dollar2)
  YYObj_Array_String_({();  append_string(_dollar1, _dollar2) })
}

// file:///./kaleidoscope.mbty
// 81|    param_list              { $1 }
fn yy_action_6(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Array_String_(_dollar1)
  YYObj_Array_String_({();  _dollar1 })
}

// file:///./kaleidoscope.mbty
// 85|    IDENT                   { one_string($1) }
fn yy_action_7(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_String(_dollar1)
  YYObj_Array_String_({();  one_string(_dollar1) })
}

// file:///./kaleidoscope.mbty
// 80|    /* empty */             { empty_strings() }
fn yy_action_8(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Array_String_({();  empty_strings() })
}

// file:///./kaleidoscope.mbty
// 72|    expr ";"                  { TopLevel::AnonExpr($1) }
fn yy_action_9(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_TopLevel({();  TopLevel::AnonExpr(_dollar1) })
}

// file:///./kaleidoscope.mbty
// 118|    "for" IDENT "=" expr "," expr "in" expr
// 119|                            { Expr::For($2, $4, $6, Expr::Number(1.0), $8) }
fn yy_action_10(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[1].0 is YYObj_String(_dollar2)
  guard! _args[3].0 is YYObj_Expr(_dollar4)
  guard! _args[5].0 is YYObj_Expr(_dollar6)
  guard! _args[7].0 is YYObj_Expr(_dollar8)
  YYObj_Expr({();  Expr::For(_dollar2, _dollar4, _dollar6, Expr::Number(1.0), _dollar8) })
}

// file:///./kaleidoscope.mbty
// 120|    "for" IDENT "=" expr "," expr "," expr "in" expr
// 121|                            { Expr::For($2, $4, $6, $8, $10) }
fn yy_action_11(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[1].0 is YYObj_String(_dollar2)
  guard! _args[3].0 is YYObj_Expr(_dollar4)
  guard! _args[5].0 is YYObj_Expr(_dollar6)
  guard! _args[7].0 is YYObj_Expr(_dollar8)
  guard! _args[9].0 is YYObj_Expr(_dollar10)
  YYObj_Expr({();  Expr::For(_dollar2, _dollar4, _dollar6, _dollar8, _dollar10) })
}

// file:///./kaleidoscope.mbty
// 116|    "if" expr "then" expr "else" expr
// 117|                            { Expr::If($2, $4, $6) }
fn yy_action_12(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[1].0 is YYObj_Expr(_dollar2)
  guard! _args[3].0 is YYObj_Expr(_dollar4)
  guard! _args[5].0 is YYObj_Expr(_dollar6)
  YYObj_Expr({();  Expr::If(_dollar2, _dollar4, _dollar6) })
}

// file:///./kaleidoscope.mbty
// 115|    "(" expr ")"            { $2 }
fn yy_action_13(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[1].0 is YYObj_Expr(_dollar2)
  YYObj_Expr({();  _dollar2 })
}

// file:///./kaleidoscope.mbty
// 130|    expr                    { one_expr($1) }
fn yy_action_14(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Array_Expr_({();  one_expr(_dollar1) })
}

// file:///./kaleidoscope.mbty
// 114|    IDENT "(" args ")"      { Expr::Call($1, $3) }
fn yy_action_15(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_String(_dollar1)
  guard! _args[2].0 is YYObj_Array_Expr_(_dollar3)
  YYObj_Expr({();  Expr::Call(_dollar1, _dollar3) })
}

// file:///./kaleidoscope.mbty
// 90|    add_expr                { $1 }
fn yy_action_16(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./kaleidoscope.mbty
// 96|    add_expr "+" mul_expr   { Expr::Binary("+", $1, $3) }
fn yy_action_17(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Expr(_dollar1)
  guard! _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary("+", _dollar1, _dollar3) })
}

// file:///./kaleidoscope.mbty
// 97|    add_expr "-" mul_expr   { Expr::Binary("-", $1, $3) }
fn yy_action_18(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Expr(_dollar1)
  guard! _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary("-", _dollar1, _dollar3) })
}

// file:///./kaleidoscope.mbty
// 91|    expr "<" add_expr       { Expr::Binary("<", $1, $3) }
fn yy_action_19(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Expr(_dollar1)
  guard! _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary("<", _dollar1, _dollar3) })
}

// file:///./kaleidoscope.mbty
// 131|    arg_list "," expr       { append_expr($1, $3) }
fn yy_action_20(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Array_Expr_(_dollar1)
  guard! _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Array_Expr_({();  append_expr(_dollar1, _dollar3) })
}

// file:///./kaleidoscope.mbty
// 102|    mul_expr "*" unary_expr { Expr::Binary("*", $1, $3) }
fn yy_action_21(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Expr(_dollar1)
  guard! _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary("*", _dollar1, _dollar3) })
}

// file:///./kaleidoscope.mbty
// 103|    mul_expr "/" unary_expr { Expr::Binary("/", $1, $3) }
fn yy_action_22(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Expr(_dollar1)
  guard! _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary("/", _dollar1, _dollar3) })
}

// file:///./kaleidoscope.mbty
// 95|    mul_expr                { $1 }
fn yy_action_23(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./kaleidoscope.mbty
// 101|    unary_expr              { $1 }
fn yy_action_24(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./kaleidoscope.mbty
// 107|    "-" unary_expr          { Expr::Unary("-", $2) }
fn yy_action_25(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[1].0 is YYObj_Expr(_dollar2)
  YYObj_Expr({();  Expr::Unary("-", _dollar2) })
}

// file:///./kaleidoscope.mbty
// 108|    primary                 { $1 }
fn yy_action_26(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./kaleidoscope.mbty
// 112|    NUMBER                  { Expr::Number($1) }
fn yy_action_27(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Double(_dollar1)
  YYObj_Expr({();  Expr::Number(_dollar1) })
}

// file:///./kaleidoscope.mbty
// 126|    arg_list                { $1 }
fn yy_action_28(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Array_Expr_(_dollar1)
  YYObj_Array_Expr_({();  _dollar1 })
}

// file:///./kaleidoscope.mbty
// 125|    /* empty */             { empty_exprs() }
fn yy_action_29(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Array_Expr_({();  empty_exprs() })
}

// file:///./kaleidoscope.mbty
// 113|    IDENT                   { Expr::Variable($1) }
fn yy_action_30(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_String(_dollar1)
  YYObj_Expr({();  Expr::Variable(_dollar1) })
}

// file:///./kaleidoscope.mbty
// 60|    program         { $1 }
fn yy_action_31(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard! _args[0].0 is YYObj_Array_TopLevel_(_dollar1)
  YYObj_Array_TopLevel_({();  _dollar1 })
}

// file:///./kaleidoscope.mbty
// 64|    /* empty */     { empty_toplevels() }
fn yy_action_32(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Array_TopLevel_({();  empty_toplevels() })
}

fn yy_input(token : Token, _start_pos : Int, _end_pos : Int) -> (YYSymbol, YYObj) {
  match token {
    NUMBER(data) => (T_NUMBER, YYObj_Double(data))
    IDENT(data) => (T_IDENT, YYObj_String(data))
    DEF => (T_DEF, YYObj_Void)
    EXTERN => (T_EXTERN, YYObj_Void)
    IF => (T_IF, YYObj_Void)
    THEN => (T_THEN, YYObj_Void)
    ELSE => (T_ELSE, YYObj_Void)
    FOR => (T_FOR, YYObj_Void)
    IN => (T_IN, YYObj_Void)
    LPAREN => (T_LPAREN, YYObj_Void)
    RPAREN => (T_RPAREN, YYObj_Void)
    COMMA => (T_COMMA, YYObj_Void)
    SEMI => (T_SEMI, YYObj_Void)
    EQUAL => (T_EQUAL, YYObj_Void)
    PLUS => (T_PLUS, YYObj_Void)
    MINUS => (T_MINUS, YYObj_Void)
    STAR => (T_STAR, YYObj_Void)
    SLASH => (T_SLASH, YYObj_Void)
    LT => (T_LT, YYObj_Void)
  }
}

// [0, parse_program → • program, $]
// [1, program → •, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
// [2, program → • program SEMI, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
// [3, program → • program topdef, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
// [33, parse_program_prime → • parse_program, $]
fn yy_state_0(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    NT_parse_program => Shift(yy_state_1)
    NT_program => Shift(yy_state_2)
    T_NUMBER | T_IDENT | T_DEF | T_EXTERN | T_IF | T_FOR | T_LPAREN | T_SEMI | T_MINUS | EOI => Reduce(0, NT_program, yy_action_32)
    _ => Error
  }
}

// [33, parse_program_prime → parse_program •, $]
fn yy_state_1(_lookahead : YYSymbol) -> YYDecision {
  Accept
}

// [0, parse_program → program •, $]
// [2, program → program • SEMI, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
// [3, program → program • topdef, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
// [4, topdef → • DEF prototype expr SEMI, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
// [5, topdef → • EXTERN prototype SEMI, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
// [6, topdef → • expr SEMI, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
// [12, expr → • add_expr, SEMI / LT]
// [13, expr → • expr LT add_expr, SEMI / LT]
// [14, add_expr → • mul_expr, SEMI / PLUS / MINUS / LT]
// [15, add_expr → • add_expr PLUS mul_expr, SEMI / PLUS / MINUS / LT]
// [16, add_expr → • add_expr MINUS mul_expr, SEMI / PLUS / MINUS / LT]
// [17, mul_expr → • unary_expr, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → • mul_expr STAR unary_expr, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → • mul_expr SLASH unary_expr, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_2(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_16)
    NT_mul_expr => Shift(yy_state_17)
    NT_add_expr => Shift(yy_state_29)
    NT_expr => Shift(yy_state_49)
    T_EXTERN => Shift(yy_state_51)
    T_DEF => Shift(yy_state_61)
    NT_topdef => Shift(yy_state_65)
    T_SEMI => Shift(yy_state_66)
    EOI => Reduce(1, NT_parse_program, yy_action_31)
    _ => Error
  }
}

// [27, primary → FOR • IDENT EQUAL expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → FOR • IDENT EQUAL expr COMMA expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_3(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_4)
    _ => Error
  }
}

// [27, primary → FOR IDENT • EQUAL expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → FOR IDENT • EQUAL expr COMMA expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_4(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_EQUAL => Shift(yy_state_5)
    _ => Error
  }
}

// [12, expr → • add_expr, COMMA / LT]
// [13, expr → • expr LT add_expr, COMMA / LT]
// [14, add_expr → • mul_expr, COMMA / PLUS / MINUS / LT]
// [15, add_expr → • add_expr PLUS mul_expr, COMMA / PLUS / MINUS / LT]
// [16, add_expr → • add_expr MINUS mul_expr, COMMA / PLUS / MINUS / LT]
// [17, mul_expr → • unary_expr, COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → • mul_expr STAR unary_expr, COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → • mul_expr SLASH unary_expr, COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → FOR IDENT EQUAL • expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → FOR IDENT EQUAL • expr COMMA expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_5(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_16)
    NT_mul_expr => Shift(yy_state_17)
    NT_add_expr => Shift(yy_state_29)
    NT_expr => Shift(yy_state_40)
    _ => Error
  }
}

// [12, expr → • add_expr, THEN / LT]
// [13, expr → • expr LT add_expr, THEN / LT]
// [14, add_expr → • mul_expr, THEN / PLUS / MINUS / LT]
// [15, add_expr → • add_expr PLUS mul_expr, THEN / PLUS / MINUS / LT]
// [16, add_expr → • add_expr MINUS mul_expr, THEN / PLUS / MINUS / LT]
// [17, mul_expr → • unary_expr, THEN / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → • mul_expr STAR unary_expr, THEN / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → • mul_expr SLASH unary_expr, THEN / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, THEN / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, THEN / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, THEN / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, THEN / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, THEN / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, THEN / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, THEN / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → IF • expr THEN expr ELSE expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, THEN / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, THEN / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_6(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_16)
    NT_mul_expr => Shift(yy_state_17)
    NT_add_expr => Shift(yy_state_29)
    NT_expr => Shift(yy_state_35)
    _ => Error
  }
}

// [12, expr → • add_expr, RPAREN / LT]
// [13, expr → • expr LT add_expr, RPAREN / LT]
// [14, add_expr → • mul_expr, RPAREN / PLUS / MINUS / LT]
// [15, add_expr → • add_expr PLUS mul_expr, RPAREN / PLUS / MINUS / LT]
// [16, add_expr → • add_expr MINUS mul_expr, RPAREN / PLUS / MINUS / LT]
// [17, mul_expr → • unary_expr, RPAREN / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → • mul_expr STAR unary_expr, RPAREN / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → • mul_expr SLASH unary_expr, RPAREN / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, RPAREN / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, RPAREN / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, RPAREN / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, RPAREN / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, RPAREN / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, RPAREN / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → LPAREN • expr RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, RPAREN / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, RPAREN / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, RPAREN / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_7(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_16)
    NT_mul_expr => Shift(yy_state_17)
    NT_add_expr => Shift(yy_state_29)
    NT_expr => Shift(yy_state_33)
    _ => Error
  }
}

// [23, primary → IDENT •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → IDENT • LPAREN args RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_8(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_9)
    T_THEN | T_ELSE | T_IN | T_RPAREN | T_COMMA | T_SEMI | T_PLUS | T_MINUS | T_STAR | T_SLASH | T_LT => Reduce(1, NT_primary, yy_action_30)
    _ => Error
  }
}

// [12, expr → • add_expr, RPAREN / COMMA / LT]
// [13, expr → • expr LT add_expr, RPAREN / COMMA / LT]
// [14, add_expr → • mul_expr, RPAREN / COMMA / PLUS / MINUS / LT]
// [15, add_expr → • add_expr PLUS mul_expr, RPAREN / COMMA / PLUS / MINUS / LT]
// [16, add_expr → • add_expr MINUS mul_expr, RPAREN / COMMA / PLUS / MINUS / LT]
// [17, mul_expr → • unary_expr, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → • mul_expr STAR unary_expr, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → • mul_expr SLASH unary_expr, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → IDENT LPAREN • args RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [29, args → •, RPAREN]
// [30, args → • arg_list, RPAREN]
// [31, arg_list → • expr, RPAREN / COMMA]
// [32, arg_list → • arg_list COMMA expr, RPAREN / COMMA]
fn yy_state_9(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    NT_arg_list => Shift(yy_state_10)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_16)
    NT_mul_expr => Shift(yy_state_17)
    NT_add_expr => Shift(yy_state_29)
    NT_args => Shift(yy_state_30)
    NT_expr => Shift(yy_state_32)
    T_RPAREN => Reduce(0, NT_args, yy_action_29)
    _ => Error
  }
}

// [30, args → arg_list •, RPAREN]
// [32, arg_list → arg_list • COMMA expr, RPAREN / COMMA]
fn yy_state_10(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_11)
    T_RPAREN => Reduce(1, NT_args, yy_action_28)
    _ => Error
  }
}

// [12, expr → • add_expr, RPAREN / COMMA / LT]
// [13, expr → • expr LT add_expr, RPAREN / COMMA / LT]
// [14, add_expr → • mul_expr, RPAREN / COMMA / PLUS / MINUS / LT]
// [15, add_expr → • add_expr PLUS mul_expr, RPAREN / COMMA / PLUS / MINUS / LT]
// [16, add_expr → • add_expr MINUS mul_expr, RPAREN / COMMA / PLUS / MINUS / LT]
// [17, mul_expr → • unary_expr, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → • mul_expr STAR unary_expr, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → • mul_expr SLASH unary_expr, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [32, arg_list → arg_list COMMA • expr, RPAREN / COMMA]
fn yy_state_11(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_16)
    NT_mul_expr => Shift(yy_state_17)
    NT_expr => Shift(yy_state_22)
    NT_add_expr => Shift(yy_state_29)
    _ => Error
  }
}

// [22, primary → NUMBER •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_12(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary, yy_action_27)
}

// [21, unary_expr → primary •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_13(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_unary_expr, yy_action_26)
}

// [20, unary_expr → • MINUS unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → MINUS • unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_14(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_15)
    _ => Error
  }
}

// [20, unary_expr → MINUS unary_expr •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_15(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_unary_expr, yy_action_25)
}

// [17, mul_expr → unary_expr •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_16(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_mul_expr, yy_action_24)
}

// [14, add_expr → mul_expr •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → mul_expr • STAR unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → mul_expr • SLASH unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_17(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_SLASH => Shift(yy_state_18)
    T_STAR => Shift(yy_state_20)
    T_THEN | T_ELSE | T_IN | T_RPAREN | T_COMMA | T_SEMI | T_PLUS | T_MINUS | T_LT => Reduce(1, NT_add_expr, yy_action_23)
    _ => Error
  }
}

// [19, mul_expr → mul_expr SLASH • unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_18(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_19)
    _ => Error
  }
}

// [19, mul_expr → mul_expr SLASH unary_expr •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_19(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_mul_expr, yy_action_22)
}

// [18, mul_expr → mul_expr STAR • unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_20(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_21)
    _ => Error
  }
}

// [18, mul_expr → mul_expr STAR unary_expr •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_21(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_mul_expr, yy_action_21)
}

// [13, expr → expr • LT add_expr, RPAREN / COMMA / LT]
// [32, arg_list → arg_list COMMA expr •, RPAREN / COMMA]
fn yy_state_22(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LT => Shift(yy_state_23)
    T_RPAREN | T_COMMA => Reduce(3, NT_arg_list, yy_action_20)
    _ => Error
  }
}

// [13, expr → expr LT • add_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [14, add_expr → • mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [15, add_expr → • add_expr PLUS mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [16, add_expr → • add_expr MINUS mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [17, mul_expr → • unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → • mul_expr STAR unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → • mul_expr SLASH unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_23(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_16)
    NT_mul_expr => Shift(yy_state_17)
    NT_add_expr => Shift(yy_state_24)
    _ => Error
  }
}

// [13, expr → expr LT add_expr •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [15, add_expr → add_expr • PLUS mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [16, add_expr → add_expr • MINUS mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_24(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_MINUS => Shift(yy_state_25)
    T_PLUS => Shift(yy_state_27)
    T_THEN | T_ELSE | T_IN | T_RPAREN | T_COMMA | T_SEMI | T_STAR | T_SLASH | T_LT => Reduce(3, NT_expr, yy_action_19)
    _ => Error
  }
}

// [16, add_expr → add_expr MINUS • mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [17, mul_expr → • unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → • mul_expr STAR unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → • mul_expr SLASH unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_25(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_16)
    NT_mul_expr => Shift(yy_state_26)
    _ => Error
  }
}

// [16, add_expr → add_expr MINUS mul_expr •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → mul_expr • STAR unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → mul_expr • SLASH unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_26(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_SLASH => Shift(yy_state_18)
    T_STAR => Shift(yy_state_20)
    T_THEN | T_ELSE | T_IN | T_RPAREN | T_COMMA | T_SEMI | T_PLUS | T_MINUS | T_LT => Reduce(3, NT_add_expr, yy_action_18)
    _ => Error
  }
}

// [15, add_expr → add_expr PLUS • mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [17, mul_expr → • unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → • mul_expr STAR unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → • mul_expr SLASH unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_27(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_16)
    NT_mul_expr => Shift(yy_state_28)
    _ => Error
  }
}

// [15, add_expr → add_expr PLUS mul_expr •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → mul_expr • STAR unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → mul_expr • SLASH unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_28(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_SLASH => Shift(yy_state_18)
    T_STAR => Shift(yy_state_20)
    T_THEN | T_ELSE | T_IN | T_RPAREN | T_COMMA | T_SEMI | T_PLUS | T_MINUS | T_LT => Reduce(3, NT_add_expr, yy_action_17)
    _ => Error
  }
}

// [12, expr → add_expr •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [15, add_expr → add_expr • PLUS mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [16, add_expr → add_expr • MINUS mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_29(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_MINUS => Shift(yy_state_25)
    T_PLUS => Shift(yy_state_27)
    T_THEN | T_ELSE | T_IN | T_RPAREN | T_COMMA | T_SEMI | T_STAR | T_SLASH | T_LT => Reduce(1, NT_expr, yy_action_16)
    _ => Error
  }
}

// [24, primary → IDENT LPAREN args • RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_30(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RPAREN => Shift(yy_state_31)
    _ => Error
  }
}

// [24, primary → IDENT LPAREN args RPAREN •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_31(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(4, NT_primary, yy_action_15)
}

// [13, expr → expr • LT add_expr, RPAREN / COMMA / LT]
// [31, arg_list → expr •, RPAREN / COMMA]
fn yy_state_32(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LT => Shift(yy_state_23)
    T_RPAREN | T_COMMA => Reduce(1, NT_arg_list, yy_action_14)
    _ => Error
  }
}

// [13, expr → expr • LT add_expr, RPAREN / LT]
// [25, primary → LPAREN expr • RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_33(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LT => Shift(yy_state_23)
    T_RPAREN => Shift(yy_state_34)
    _ => Error
  }
}

// [25, primary → LPAREN expr RPAREN •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_34(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_primary, yy_action_13)
}

// [13, expr → expr • LT add_expr, THEN / LT]
// [26, primary → IF expr • THEN expr ELSE expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_35(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LT => Shift(yy_state_23)
    T_THEN => Shift(yy_state_36)
    _ => Error
  }
}

// [12, expr → • add_expr, ELSE / LT]
// [13, expr → • expr LT add_expr, ELSE / LT]
// [14, add_expr → • mul_expr, ELSE / PLUS / MINUS / LT]
// [15, add_expr → • add_expr PLUS mul_expr, ELSE / PLUS / MINUS / LT]
// [16, add_expr → • add_expr MINUS mul_expr, ELSE / PLUS / MINUS / LT]
// [17, mul_expr → • unary_expr, ELSE / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → • mul_expr STAR unary_expr, ELSE / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → • mul_expr SLASH unary_expr, ELSE / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, ELSE / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, ELSE / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, ELSE / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, ELSE / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, ELSE / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, ELSE / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, ELSE / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → IF expr THEN • expr ELSE expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, ELSE / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, ELSE / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_36(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_16)
    NT_mul_expr => Shift(yy_state_17)
    NT_add_expr => Shift(yy_state_29)
    NT_expr => Shift(yy_state_37)
    _ => Error
  }
}

// [13, expr → expr • LT add_expr, ELSE / LT]
// [26, primary → IF expr THEN expr • ELSE expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_37(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LT => Shift(yy_state_23)
    T_ELSE => Shift(yy_state_38)
    _ => Error
  }
}

// [12, expr → • add_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [13, expr → • expr LT add_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [14, add_expr → • mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [15, add_expr → • add_expr PLUS mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [16, add_expr → • add_expr MINUS mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [17, mul_expr → • unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → • mul_expr STAR unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → • mul_expr SLASH unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → IF expr THEN expr ELSE • expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_38(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_16)
    NT_mul_expr => Shift(yy_state_17)
    NT_add_expr => Shift(yy_state_29)
    NT_expr => Shift(yy_state_39)
    _ => Error
  }
}

// [13, expr → expr • LT add_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → IF expr THEN expr ELSE expr •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_39(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LT => Shift(yy_state_23)
    T_THEN | T_ELSE | T_IN | T_RPAREN | T_COMMA | T_SEMI | T_PLUS | T_MINUS | T_STAR | T_SLASH => Reduce(6, NT_primary, yy_action_12)
    _ => Error
  }
}

// [13, expr → expr • LT add_expr, COMMA / LT]
// [27, primary → FOR IDENT EQUAL expr • COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → FOR IDENT EQUAL expr • COMMA expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_40(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LT => Shift(yy_state_23)
    T_COMMA => Shift(yy_state_41)
    _ => Error
  }
}

// [12, expr → • add_expr, IN / COMMA / LT]
// [13, expr → • expr LT add_expr, IN / COMMA / LT]
// [14, add_expr → • mul_expr, IN / COMMA / PLUS / MINUS / LT]
// [15, add_expr → • add_expr PLUS mul_expr, IN / COMMA / PLUS / MINUS / LT]
// [16, add_expr → • add_expr MINUS mul_expr, IN / COMMA / PLUS / MINUS / LT]
// [17, mul_expr → • unary_expr, IN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → • mul_expr STAR unary_expr, IN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → • mul_expr SLASH unary_expr, IN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, IN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, IN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, IN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, IN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, IN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, IN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, IN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, IN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → FOR IDENT EQUAL expr COMMA • expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, IN / COMMA / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → FOR IDENT EQUAL expr COMMA • expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_41(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_16)
    NT_mul_expr => Shift(yy_state_17)
    NT_add_expr => Shift(yy_state_29)
    NT_expr => Shift(yy_state_42)
    _ => Error
  }
}

// [13, expr → expr • LT add_expr, IN / COMMA / LT]
// [27, primary → FOR IDENT EQUAL expr COMMA expr • IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → FOR IDENT EQUAL expr COMMA expr • COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_42(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LT => Shift(yy_state_23)
    T_COMMA => Shift(yy_state_43)
    T_IN => Shift(yy_state_47)
    _ => Error
  }
}

// [12, expr → • add_expr, IN / LT]
// [13, expr → • expr LT add_expr, IN / LT]
// [14, add_expr → • mul_expr, IN / PLUS / MINUS / LT]
// [15, add_expr → • add_expr PLUS mul_expr, IN / PLUS / MINUS / LT]
// [16, add_expr → • add_expr MINUS mul_expr, IN / PLUS / MINUS / LT]
// [17, mul_expr → • unary_expr, IN / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → • mul_expr STAR unary_expr, IN / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → • mul_expr SLASH unary_expr, IN / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, IN / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, IN / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, IN / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, IN / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, IN / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, IN / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, IN / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, IN / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, IN / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → FOR IDENT EQUAL expr COMMA expr COMMA • expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_43(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_16)
    NT_mul_expr => Shift(yy_state_17)
    NT_add_expr => Shift(yy_state_29)
    NT_expr => Shift(yy_state_44)
    _ => Error
  }
}

// [13, expr → expr • LT add_expr, IN / LT]
// [28, primary → FOR IDENT EQUAL expr COMMA expr COMMA expr • IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_44(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LT => Shift(yy_state_23)
    T_IN => Shift(yy_state_45)
    _ => Error
  }
}

// [12, expr → • add_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [13, expr → • expr LT add_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [14, add_expr → • mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [15, add_expr → • add_expr PLUS mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [16, add_expr → • add_expr MINUS mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [17, mul_expr → • unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → • mul_expr STAR unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → • mul_expr SLASH unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → FOR IDENT EQUAL expr COMMA expr COMMA expr IN • expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_45(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_16)
    NT_mul_expr => Shift(yy_state_17)
    NT_add_expr => Shift(yy_state_29)
    NT_expr => Shift(yy_state_46)
    _ => Error
  }
}

// [13, expr → expr • LT add_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_46(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LT => Shift(yy_state_23)
    T_THEN | T_ELSE | T_IN | T_RPAREN | T_COMMA | T_SEMI | T_PLUS | T_MINUS | T_STAR | T_SLASH => Reduce(10, NT_primary, yy_action_11)
    _ => Error
  }
}

// [12, expr → • add_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [13, expr → • expr LT add_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [14, add_expr → • mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [15, add_expr → • add_expr PLUS mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [16, add_expr → • add_expr MINUS mul_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [17, mul_expr → • unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → • mul_expr STAR unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → • mul_expr SLASH unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → FOR IDENT EQUAL expr COMMA expr IN • expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_47(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_16)
    NT_mul_expr => Shift(yy_state_17)
    NT_add_expr => Shift(yy_state_29)
    NT_expr => Shift(yy_state_48)
    _ => Error
  }
}

// [13, expr → expr • LT add_expr, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → FOR IDENT EQUAL expr COMMA expr IN expr •, THEN / ELSE / IN / RPAREN / COMMA / SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_48(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LT => Shift(yy_state_23)
    T_THEN | T_ELSE | T_IN | T_RPAREN | T_COMMA | T_SEMI | T_PLUS | T_MINUS | T_STAR | T_SLASH => Reduce(8, NT_primary, yy_action_10)
    _ => Error
  }
}

// [6, topdef → expr • SEMI, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
// [13, expr → expr • LT add_expr, SEMI / LT]
fn yy_state_49(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LT => Shift(yy_state_23)
    T_SEMI => Shift(yy_state_50)
    _ => Error
  }
}

// [6, topdef → expr SEMI •, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
fn yy_state_50(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_topdef, yy_action_9)
}

// [5, topdef → EXTERN • prototype SEMI, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
// [7, prototype → • IDENT LPAREN params RPAREN, SEMI]
fn yy_state_51(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_52)
    NT_prototype => Shift(yy_state_59)
    _ => Error
  }
}

// [7, prototype → IDENT • LPAREN params RPAREN, NUMBER / IDENT / IF / FOR / LPAREN / SEMI / MINUS]
fn yy_state_52(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_53)
    _ => Error
  }
}

// [7, prototype → IDENT LPAREN • params RPAREN, NUMBER / IDENT / IF / FOR / LPAREN / SEMI / MINUS]
// [8, params → •, RPAREN]
// [9, params → • param_list, RPAREN]
// [10, param_list → • IDENT, IDENT / RPAREN]
// [11, param_list → • param_list IDENT, IDENT / RPAREN]
fn yy_state_53(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_54)
    NT_param_list => Shift(yy_state_55)
    NT_params => Shift(yy_state_57)
    T_RPAREN => Reduce(0, NT_params, yy_action_8)
    _ => Error
  }
}

// [10, param_list → IDENT •, IDENT / RPAREN]
fn yy_state_54(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_param_list, yy_action_7)
}

// [9, params → param_list •, RPAREN]
// [11, param_list → param_list • IDENT, IDENT / RPAREN]
fn yy_state_55(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_56)
    T_RPAREN => Reduce(1, NT_params, yy_action_6)
    _ => Error
  }
}

// [11, param_list → param_list IDENT •, IDENT / RPAREN]
fn yy_state_56(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_param_list, yy_action_5)
}

// [7, prototype → IDENT LPAREN params • RPAREN, NUMBER / IDENT / IF / FOR / LPAREN / SEMI / MINUS]
fn yy_state_57(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RPAREN => Shift(yy_state_58)
    _ => Error
  }
}

// [7, prototype → IDENT LPAREN params RPAREN •, NUMBER / IDENT / IF / FOR / LPAREN / SEMI / MINUS]
fn yy_state_58(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(4, NT_prototype, yy_action_4)
}

// [5, topdef → EXTERN prototype • SEMI, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
fn yy_state_59(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_SEMI => Shift(yy_state_60)
    _ => Error
  }
}

// [5, topdef → EXTERN prototype SEMI •, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
fn yy_state_60(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_topdef, yy_action_3)
}

// [4, topdef → DEF • prototype expr SEMI, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
// [7, prototype → • IDENT LPAREN params RPAREN, NUMBER / IDENT / IF / FOR / LPAREN / MINUS]
fn yy_state_61(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_52)
    NT_prototype => Shift(yy_state_62)
    _ => Error
  }
}

// [4, topdef → DEF prototype • expr SEMI, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
// [12, expr → • add_expr, SEMI / LT]
// [13, expr → • expr LT add_expr, SEMI / LT]
// [14, add_expr → • mul_expr, SEMI / PLUS / MINUS / LT]
// [15, add_expr → • add_expr PLUS mul_expr, SEMI / PLUS / MINUS / LT]
// [16, add_expr → • add_expr MINUS mul_expr, SEMI / PLUS / MINUS / LT]
// [17, mul_expr → • unary_expr, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [18, mul_expr → • mul_expr STAR unary_expr, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [19, mul_expr → • mul_expr SLASH unary_expr, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [20, unary_expr → • MINUS unary_expr, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [21, unary_expr → • primary, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [22, primary → • NUMBER, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [23, primary → • IDENT, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [24, primary → • IDENT LPAREN args RPAREN, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [25, primary → • LPAREN expr RPAREN, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [26, primary → • IF expr THEN expr ELSE expr, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [27, primary → • FOR IDENT EQUAL expr COMMA expr IN expr, SEMI / PLUS / MINUS / STAR / SLASH / LT]
// [28, primary → • FOR IDENT EQUAL expr COMMA expr COMMA expr IN expr, SEMI / PLUS / MINUS / STAR / SLASH / LT]
fn yy_state_62(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FOR => Shift(yy_state_3)
    T_IF => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_8)
    T_NUMBER => Shift(yy_state_12)
    NT_primary => Shift(yy_state_13)
    T_MINUS => Shift(yy_state_14)
    NT_unary_expr => Shift(yy_state_16)
    NT_mul_expr => Shift(yy_state_17)
    NT_add_expr => Shift(yy_state_29)
    NT_expr => Shift(yy_state_63)
    _ => Error
  }
}

// [4, topdef → DEF prototype expr • SEMI, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
// [13, expr → expr • LT add_expr, SEMI / LT]
fn yy_state_63(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LT => Shift(yy_state_23)
    T_SEMI => Shift(yy_state_64)
    _ => Error
  }
}

// [4, topdef → DEF prototype expr SEMI •, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
fn yy_state_64(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(4, NT_topdef, yy_action_2)
}

// [3, program → program topdef •, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
fn yy_state_65(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_program, yy_action_1)
}

// [2, program → program SEMI •, $ / NUMBER / IDENT / DEF / EXTERN / IF / FOR / LPAREN / SEMI / MINUS]
fn yy_state_66(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_program, yy_action_0)
}

fn[T] yy_parse(
  tokens : Array[(Token, Int, Int)],
  start : YYState,
  return_ : (YYObj) -> T,
  initial_pos? : Int,
) -> T raise ParseError {
  let mut cursor = 0
  let mut state_stack : @list.List[YYState] = @list.cons(start, @list.empty())
  let data_stack : Array[(YYObj, Int, Int)] = []
  let mut last_pos = initial_pos.unwrap_or(tokens[0].1)
  let mut state = start
  let mut lookahead : Option[(YYSymbol, (YYObj, Int, Int), Token?)] = None
  let mut last_shifted_state_stack = state_stack
  while true {
    let decision = match state(EOI) {
      ReduceNoLookahead(_) | Accept as t => t
      _ => {
        match lookahead {
          Some(la) => state(la.0)
          None => {
            if cursor < tokens.length() {
              let (token, start_pos, end_pos) = tokens[cursor]
              cursor += 1
              let (symbol, data) = yy_input(token, start_pos, end_pos)
              lookahead = Some((symbol, (data, start_pos, end_pos), Some(token)))
              state(symbol)
            } else {
              lookahead = Some((EOI, (YYObj_Void, last_pos, last_pos), None))
              state(EOI)
            }
          }
        }
      }
    }
    match decision {
      Accept => return return_(data_stack.unsafe_pop().0)
      Shift(next_state) => {
        guard! lookahead is Some(la)
        data_stack.push(la.1)
        state_stack = @list.cons(next_state, state_stack)
        last_shifted_state_stack = state_stack
        state = next_state
        last_pos = la.1.2
        lookahead = None
      }
      Reduce(count, symbol, action)
      | ReduceNoLookahead(count, symbol, action) => {
        for count = count, symbol = symbol, action = action {
          let args = data_stack[data_stack.length() - count:]
          let data = action(last_pos, args)
          let (start_pos, end_pos) = if args.length() == 0 {
            (last_pos, last_pos)
          } else {
            (args[0].1, args[args.length() - 1].2)
          }
          for _ in 0..<count {
            ignore(data_stack.unsafe_pop())
            state_stack = state_stack.unsafe_tail()
          }
          state = state_stack.unsafe_head()
          data_stack.push((data, start_pos, end_pos))
          match state(symbol) {
            Accept => return return_(data_stack.unsafe_pop().0)
            Shift(next_state) => {
              state_stack = @list.cons(next_state, state_stack)
              state = next_state
              break ()
            }
            Reduce(count, symbol, action)
            | ReduceNoLookahead(count, symbol, action) => continue count, symbol, action
            _ => panic()
          }
        }
      }
      Error => {
        let (_, (_, start_pos, end_pos), token) = lookahead.unwrap()
        error(last_shifted_state_stack, token, (start_pos, end_pos))
      }
    }
  }
  panic()
}

fn error(stack : @list.List[YYState], token : Token?, loc : (Int, Int)) -> Unit raise ParseError {
  let expected = []
  fn try_add(symbol : YYSymbol, kind : TokenKind) {
    fn go(stack : @list.List[YYState]) {
      match stack {
        Empty => ()
        More(state, ..) => {
          match state(symbol) {
            Accept | Shift(_) => expected.push(kind)
            Reduce(count, symbol, _) | ReduceNoLookahead(count, symbol, _) => {
              fn inner_go(stack : @list.List[YYState], count, symbol) {
                let stack = stack.drop(count)
                guard! stack is More(state, ..)
                match state(symbol) {
                  Shift(state) => go(@list.cons(state, stack))
                  Reduce(count, symbol, _) | ReduceNoLookahead(count, symbol, _) => inner_go(stack, count, symbol)
                  _ => panic()
                }
              }
              inner_go(stack, count, symbol)
            }
            Error => ()
          }
        }
      }
    }
    go(stack)
  }
  for term in ([(T_NUMBER, TK_NUMBER), (T_IDENT, TK_IDENT), (T_DEF, TK_DEF), (T_EXTERN, TK_EXTERN), (T_IF, TK_IF), (T_THEN, TK_THEN), (T_ELSE, TK_ELSE), (T_FOR, TK_FOR), (T_IN, TK_IN), (T_LPAREN, TK_LPAREN), (T_RPAREN, TK_RPAREN), (T_COMMA, TK_COMMA), (T_SEMI, TK_SEMI), (T_EQUAL, TK_EQUAL), (T_PLUS, TK_PLUS), (T_MINUS, TK_MINUS), (T_STAR, TK_STAR), (T_SLASH, TK_SLASH), (T_LT, TK_LT)] : Array[(YYSymbol, TokenKind)]) {
    try_add(term.0, term.1)
  }
  match token {
    None => raise UnexpectedEndOfInput(loc.1, expected)
    Some(token) => raise UnexpectedToken(token, loc, expected)
  }
}

pub fn parse_program(tokens : Array[(Token, Int, Int)], initial_pos? : Int) -> Array[TopLevel] raise ParseError {
  yy_parse(
    tokens,
    yy_state_0,
    (it) => {
      guard! it is YYObj_Array_TopLevel_(result)
      result
    },
    initial_pos?,
  )
}

