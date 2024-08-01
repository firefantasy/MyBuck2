# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under both the MIT license found in the
# LICENSE-MIT file in the root directory of this source tree and the Apache
# License, Version 2.0 found in the LICENSE-APACHE file in the root directory
# of this source tree.

def assert_output(name, command, output):
    return native.genrule(
        name = name,
        bash = command + " | grep \"" + output + "\" && touch \"$OUT\"",
        cmd_exe = command + " | findstr \"" + output + "\" && type nul > \"$OUT\"",
        out = "out.txt",
    )

def haskell_library(deps = [], **kwargs):
    native.haskell_library(
        deps = deps + ["//third-party/haskell:base"],
        **kwargs
    )

def haskell_binary(linker_flags = [], deps = [], **kwargs):
    native.haskell_binary(
        # Workaround for as yet not triaged runtime segfault.
        linker_flags = linker_flags + ["-dynamic"] if host_info().os.is_macos else linker_flags,
        deps = deps + ["//third-party/haskell:base"],
        **kwargs
    )
