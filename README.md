# Kaleidoscope in MoonBit

A complete [Kaleidoscope](https://llvm.org/docs/tutorial/MyFirstLanguageFrontend/LangImpl01.html)-style
compiler demo written in MoonBit, built from three pieces of the MoonBit
ecosystem:

| Layer | Technology | Location |
| --- | --- | --- |
| Lexer | MoonBit `lexscan` / `lexmatch` language features over `@lexbuf.StringScanner` | [`lexer/`](lexer/lexer.mbt) |
| Parser | [MoonYacc](https://github.com/moonbitlang/moonyacc) LR(1) generator, grammar in `.mbty`, generated parser committed | [`parser/`](parser/kaleidoscope.mbty) |
| Backend | [llvm.mbt](https://github.com/moonbitlang/llvm.mbt) (`Kaida-Amethyst/llvm`) IR building + ORC LLJIT | [`codegen/`](codegen/codegen.mbt) |

Source text flows through `lexscan`-driven tokens -> the moonyacc LR parser into
an AST -> verified LLVM IR -> either printed IR or in-process JIT execution.

## Requirements

- MoonBit toolchain (developed against `moon 0.1.20260827`)
- A supported host: **macOS (ARM64)** or **Linux (x86_64)** — the two platforms
  for which `Kaida-Amethyst/llvm` ships prebuilt LLVM artifacts. No system LLVM
  is needed; the first native build downloads ~29 MiB of LLVM into the Moon
  shared cache (`~/.moon`).

The lexer/parser unit tests additionally run on `js` and `wasm` targets.

## Run it

```sh
# Print the generated LLVM IR
moon run --target native main -- examples/fibonacci.kl

# Compile and execute with the in-process LLJIT
moon run --target native main --run -- examples/fibonacci.kl
# => 55

moon run --target native main --run -- examples/control.kl
# => 100
#    -1
#    7
#    10
#    0
```

Read from stdin with a file argument of `-` (the default):

```sh
echo 'def add(x y) x + y; add(20, 22);' | moon run --target native main --run
# => 42
```

## Language

Every runtime value is a `double`.

```text
top-level  ::= "def" prototype expr ";"
             | "extern" prototype ";"
             | expr ";"

prototype  ::= identifier "(" identifiers... ")"

expr       ::= number | identifier | call | "(" expr ")"
             | unary "-" expr
             | expr ("+" | "-" | "*" | "/" | "<") expr
             | "if" expr "then" expr "else" expr
             | "for" identifier "=" expr "," expr ("," expr)? "in" expr
```

- Built-in binary operators are `< + - * /`. `<` returns `1.0` or `0.0`;
  precedence follows the layered grammar (`* /` > `+ -` > `<`, unary `-`
  binds tightest).
- `def` defines a function, `extern` declares a foreign one. Calls need a
  declared prototype with a matching argument count.
- `if`/`then`/`else` branches and `for` bodies are *greedy*: `if c then a else
  b < x` means `if c then a else (b < x)`.
- `for var = start, cond, step in body` runs its body once, then advances by
  `step` (default `1.0`) and tests `cond`; the loop expression evaluates to
  `0.0` (like a C `for` statement).
- **Every top-level item must be terminated by `;`** — bare adjacency between
  constructs is a parse error. This is what keeps the LR grammar
  conflict-free (see `parser/kaleidoscope.mbty`).
- `#` starts a comment running to the end of the line.

### Known limitations (vs. the full LLVM tutorial)

- No `var` bindings, assignment, or user-defined `binary`/`unary` operators.
- `extern` calls are resolved from host-process symbols by LLJIT at runtime;
  in `--run` mode an unresolvable extern fails at the JIT lookup that needs
  it, while `extern` declarations alone are fine.
- No optimization passes or debug info: modules are verified but otherwise
  emitted as-is.

## Project layout

```text
lexer/    tokenizer: @lexbuf.StringScanner + one lexscan per token
parser/   AST (ast.mbt) + MoonYacc grammar + committed generated parser
codegen/  AST -> verified LLVM IR module (llvm.mbt)
main/     native CLI: file/stdin in, IR out, or --run via LLJIT
examples/ .kl demo sources
```

The generated parser (`parser/kaleidoscope_parser.mbt`) is committed. Regenerate
it after editing the grammar from the `parser/` directory with:

```sh
moonx --target native moonbitlang/yacc -- kaleidoscope.mbty \
  --input-mode array -o kaleidoscope_parser.mbt
moon check
```

(The grammar reports **zero** shift/reduce conflicts. Note that
`moonx --target native` is deprecated upstream after 2026-09-14; the sandboxed
wasm route cannot write the output file.) `parser/kaleidoscope_parser.mbt.map.json`
is moonyacc's source map, kept so diagnostics point back at the `.mbty`.

## Testing

```sh
moon test lexer parser --target js      # frontend unit tests
moon test lexer parser --target wasm
moon test codegen  --target native      # real LLVM IR generation (links LLVM)
moon build --target native main         # CLI links
moon fmt --check && moon check --deny-warn
```

Coverage: tokenization rules and offsets, parser precedence/associativity and
AST shapes, LLVM IR lowering (arithmetic, calls, externs, if/phi, for loops,
nested control flow), plus the end-to-end JIT smoke test in CI
(`.github/workflows/ci.yml`, running on Linux x86_64 and macOS ARM64).
