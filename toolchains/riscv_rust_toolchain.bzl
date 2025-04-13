load("@prelude//rust:rust_toolchain.bzl", "RustToolchainInfo")


def _riscv_rust_toolchain_impl(ctx):
    return [
        DefaultInfo(),
        RustToolchainInfo(
            rustc_target_triple = ctx.attrs.rustc_target_triple,
        ),
    ]

riscv_rust_toolchain = rule(
    impl = _riscv_rust_toolchain_impl,
    attrs = {
        "rustc_target_triple": attrs.string(default = "riscv64gc-unknown-linux-gnu"),
    },
    is_toolchain_rule = True,
)
