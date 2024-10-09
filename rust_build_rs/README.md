# A rustlang build project that links to a dynamic library

This project will throught two different approach to build. One is by `build.rs`, the other one is `buck2`.

## `build.rs`

the `src\greet.c` is the c souce code that defined the `greet` function. 
Thougt in this example we don't use `cc` crate to build the dynamic file, we mananually build it into a dynamic file by `gcc greet.c -shared -o libgreet.so`

Add this to the `build.rs` under the root path.
```
fn main() {
    // dynatic link against libgreet.so'
    // NB: the linker actually looks for a file with a 'lib' prefix
    println!("cargo::rustc-link-search=native=/root/workspace/buck2/rust_build_rs/src");
    println!("cargo::rustc-link-lib=dylib=greet");
    // This will add absolute path of the dynamic library to the rpath
    // println!("cargo:rustc-link-arg=-Wl,-rpath,/root/workspace/buck2/rust_build_rs/src");
}

```

we indirectly tell rustc how to link to dynamic library by transfer these instructions to cargo.

```
println!("cargo::rustc-link-search=native=/root/workspace/buck2/rust_build_rs/src");
println!("cargo::rustc-link-lib=dylib=greet");
```

this equvalient to direct call `rustc main.rs  -Lnative=/root/workspace/buck2/rust_build_rs/src -ldylib=greet`

Run `cargo build` to generate the binary file, and run `LD_LIBRARY_PATH=. ../target/debug/rust_build_rs`

```
➜  src git:(main) ✗ LD_LIBRARY_PATH=. ../target/debug/rust_build_rs
Hello, world!
```

Beware dynamic path can be embed into the binary file by `-Wl,-rpath,$ORIGIN/../../src`. 
Be careful to escape $ORIGIN properly for your shell, and remember that the path is relative to the executable, not the current working directory. 
See https://stackoverflow.com/questions/40602708/linking-rust-application-with-a-dynamic-library-not-in-the-runtime-linker-search/40644750#40644750


If you want `cc` crate to process the whole dynamic compile, 

```
    println!("cargo::rerun-if-changed=src/greet.c");
    cc::Build::new()
        .file("src/greet.c")
        .shared_flag(true)
        .compile("greet");
```


## `Buck2`

The `Buck2` build tool can take place of the `build.rs` in some way.

In the project root, type `buck2 init` to generate the `BUCK` file the buck2 needed.

we can direct pass the flag to `rustc` to build.

```
rust_binary(
    name = "main",
    srcs = glob(
        ["src/*.rs"],
    ),
    # Directy pass the rustc flags
    rustc_flags = ["-Lnative=/root/workspace/buck2/rust_build_rs/src", "-ldylib=greet"]
)

```

the buck2 is a multiple language build tool, so we can directly define a cxx_library as our rust_linary dependency.

```
cxx_library(
    name = "greet",
    srcs = glob(
        ["src/*.c"],
    )
)

rust_binary(
    name = "main",
    srcs = glob(
        ["src/*.rs"],
    ),
    deps = [":greet"],
    # Way 2: Directy pass the rustc flags
    rustc_flags = ["-Lnative=/root/workspace/buck2/rust_build_rs/src", "-ldylib=greet"]
)

```

This will build the c code firsly, and then build the rust code and dynamic to it.

```
➜  src git:(main) ✗ buck2 build //:main --show-output -v 4
Starting new buck2 daemon...
Connected to new buck2 daemon.
Running action: root//:greet (prelude//platforms:default#904931f735703749) (c_compile src/greet.c (pic)) (build), local executor: env -- 'TMPDIR=/root/workspace/buck2/rust_build_rs/buck-out/v2/tmp/root/215ce154fdd109a9/c_compile/_buck_56f3a042d15da849' 'BUCK_SCRATCH_PATH=buck-out/v2/tmp/root/215ce154fdd109a9/c_compile/_buck_56f3a042d15da849' 'BUCK2_DAEMON_UUID=af3873c7-def7-4e9e-b849-b347ed14f8ac' 'BUCK_BUILD_ID=eed87a9f-b536-437a-914f-cbed56cfad4d' clang -o buck-out/v2/gen/root/904931f735703749/__greet__/__objects__/src/greet.c.pic.o -fPIC @buck-out/v2/gen/root/904931f735703749/__greet__/.c.cxx_compile_argsfile -c src/greet.c
Running action: root//:greet (prelude//platforms:default#904931f735703749) (archive libgreet.pic.a) (build), local executor: env -- 'TMPDIR=/root/workspace/buck2/rust_build_rs/buck-out/v2/tmp/root/c268f812678e8958/archive/libgreet.pic.a' 'BUCK_SCRATCH_PATH=buck-out/v2/tmp/root/c268f812678e8958/archive/libgreet.pic.a' 'BUCK2_DAEMON_UUID=af3873c7-def7-4e9e-b849-b347ed14f8ac' 'BUCK_BUILD_ID=eed87a9f-b536-437a-914f-cbed56cfad4d' ar qcsD buck-out/v2/gen/root/904931f735703749/__greet__/libgreet.pic.a @buck-out/v2/gen/root/904931f735703749/__greet__/libgreet.pic.a.cxx_archive_argsfile
Running action: root//:main (prelude//platforms:default#904931f735703749) (rustc link [pic]) (build), local executor: env -- 'TMPDIR=/root/workspace/buck2/rust_build_rs/buck-out/v2/tmp/root/4566ad0e6a7c48c8/rustc/_buck_c5a998e79d3a718a' 'BUCK_SCRATCH_PATH=buck-out/v2/tmp/root/4566ad0e6a7c48c8/rustc/_buck_c5a998e79d3a718a' 'BUCK2_DAEMON_UUID=af3873c7-def7-4e9e-b849-b347ed14f8ac' 'BUCK_BUILD_ID=eed87a9f-b536-437a-914f-cbed56cfad4d' /usr/bin/env 'PYTHONPATH=buck-out/v2/gen/prelude/904931f735703749/rust/tools/__rustc_action__/__rustc_action__' python3 buck-out/v2/gen/prelude/904931f735703749/rust/tools/__rustc_action__/rustc_action.py @buck-out/v2/gen/root/904931f735703749/__main__/bin-pic-static_pic-link/main-link-diag.args
Build ID: eed87a9f-b536-437a-914f-cbed56cfad4d
Jobs completed: 76. Time elapsed: 0.9s.
Cache hits: 0%. Commands: 3 (cached: 0, remote: 0, local: 3)
BUILD SUCCEEDED
root//:main buck-out/v2/gen/root/904931f735703749/__main__/main
```


Also it can be directly run.
```
➜  src git:(main) ✗ buck2 run //:main -- --show-output
Build ID: f9ff744e-25af-4eac-93eb-bca304579a2e
Jobs completed: 3. Time elapsed: 0.0s.
BUILD SUCCEEDED
Hello, world!
```