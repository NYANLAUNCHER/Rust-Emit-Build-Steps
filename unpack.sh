#!/usr/bin/env bash
set -euo pipefail

CRATE=projectname
OUT=compiler_dump

mkdir -p "$OUT"

echo "== rustc version =="
rustc --version

echo "== cleaning =="
cargo clean

echo "== building with rustc flags =="

RUSTFLAGS="-Zunstable-options --pretty=expanded"

# ----------------------------
# 1. Expanded source
# ----------------------------
echo "== expanded source =="
cargo rustc --bin "$CRATE" -- \
  > "$OUT/01-expanded.rs"

# ----------------------------
# 2. HIR (pretty printed)
# ----------------------------
echo "== HIR =="
cargo rustc --bin "$CRATE" -- \
  -Zunpretty=hir \
  > "$OUT/02-hir.txt"

# ----------------------------
# 3. MIR
# ----------------------------
echo "== MIR =="
cargo rustc --bin "$CRATE" -- \
  -Zdump-mir=all \
  -Zdump-mir-dir="$OUT/mir"

# ----------------------------
# 4. LLVM IR
# ----------------------------
echo "== LLVM IR =="
cargo rustc --bin "$CRATE" -- \
  --emit=llvm-ir

find target/debug -name "*.ll" -exec cp {} "$OUT/" \;

# ----------------------------
# 5. Assembly
# ----------------------------
echo "== Assembly =="
cargo rustc --bin "$CRATE" -- \
  --emit=asm

find target/debug -name "*.s" -exec cp {} "$OUT/" \;

# ----------------------------
# 6. Object files
# ----------------------------
echo "== Object files =="
cargo rustc --bin "$CRATE" -- \
  --emit=obj

find target/debug -name "*.o" -exec cp {} "$OUT/" \;

# ----------------------------
# 7. Compiler timings
# ----------------------------
echo "== Timings =="
cargo rustc --bin "$CRATE" -- \
  -Ztime-passes \
  -Zself-profile

echo
echo "Artifacts written to: $OUT"

