#[allow(unused_parens)]
fn greet() -> (fn(&str) -> String) {
  fn f(s: &str) -> String {
    let p = format!("Hello {}.", s);
    p
  }
  return f;
}

fn p(name: &str) -> impl FnOnce() -> String {
  let s = format!("Hello {}", name);
  move || s
}

fn main() {
  println!("{}", greet()("dave"));
  println!("{}", p("dave")());
}
