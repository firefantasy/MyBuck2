# Buck2 try steps

The codebase includes `with_prelude` and `no_prelude`, these all about how to use buck2 to build on rustlang project.

All the demo can be found on https://github.com/facebook/buck2/tree/main/examples, but our steps is focus to build rustlang project.


## Build the rustlang project with default `toolchain`

Buck2 support multiple luagueages, and all these need a toolchain, people can customnize their exclusize toolchain, or we can use the 
default toolchain to quickly build our project. The default toolchains provides by buck2 thought `buck2 init`, by these, the `toolchains` folder will be generated in current folder.


This is the reproduce step to build a rust helloworld project

- create root folder, call `with_prelude`, keep in mind buck2 has a root folder, 
- into the `with_prelude` folder and run `buck2 init --git`, this will generate the `toolchains` and make the `with_prelude` into a git repos. And in the same time, the `buck-output` will added into the `.gitignore`
- then copy the `test_utils.bzl`, `rust`, `BUCK` from `https://github.com/facebook/buck2/tree/main/examples/with_prelude`

the final contents in `with_prelude` will be like

```
tree
.
├── BUCK
├── rust
│   ├── BUCK
│   ├── bin
│   │   └── main.rs
│   ├── src
│   │   └── lib.rs
│   └── test
│       └── test.rs
├── test_utils.bzl
└── toolchains
    └── BUCK
```



build : `buck2 build root//rust:main`

test: `buck2 test root//rust:test`

the `root` prefix can be elided, `/` represents the `root` as well, `rust` is the folder, and `main` or `test` is the build name defined in the BUCK file.

## Build with custom toolchain

In this step, we try to use our custom toolchain to build.

All the informations are from `https://github.com/facebook/buck2/tree/main/examples/no_prelude`

- create a folder named `no_prelude`
- copy `BUCK`, `rust`, `.buckroot`, `.buckconfig` from `https://github.com/facebook/buck2/tree/main/examples/no_prelude`

The final contents in `no_prelude` folder

```
tree
.
├── BUCK
├── rust
│   ├── BUCK
│   ├── main.rs
│   └── rules.bzl
└── toolchains
    ├── BUCK
    └── rust_toolchain.bzl
```
 
The custom toolchain is defined `.buckconfig`, which specified in the `toolchains` folder. We defined the `rust_toolchain.bzl` as the toolchain.


## where is the output

All the output will be generate in the `buck-out`, if you accidentily delete it then you need to restart the buck' daemon process.

```
buck2 kill 

```


