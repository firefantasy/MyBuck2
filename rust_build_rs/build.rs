fn main() {
    // dynatic link against libgreet.so'
    // NB: the linker actually looks for a file with a 'lib' prefix
    println!("cargo::rustc-link-search=native=./src");
    println!("cargo::rustc-link-lib=dylib=greet");
    // This will add absolute path of the dynamic library to the rpath
    println!("cargo:rustc-link-arg=-Wl,-rpath,$ORIGIN/../../src");
}
