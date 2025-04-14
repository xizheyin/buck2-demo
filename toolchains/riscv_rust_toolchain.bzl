load("@prelude//cxx:cxx_toolchain_types.bzl", "CxxPlatformInfo", "CxxToolchainInfo", "LinkerInfo", "LinkerType")
load("@prelude//rust:rust_toolchain.bzl", "PanicRuntime", "RustToolchainInfo")

def _riscv_cxx_toolchain_impl(ctx: AnalysisContext) -> list[Provider]:
    base = ctx.attrs.base[CxxToolchainInfo]

    linker_info = {
        field: getattr(base.linker_info, field)
        for field in dir(base.linker_info)
    } | dict(
        linker = RunInfo(ctx.attrs.linker),
        linker_flags = ctx.attrs.linker_flags,
        type = LinkerType(ctx.attrs.linker_type),
    )

    cxx_toolchain_info = {
        field: getattr(base, field)
        for field in dir(base)
    } | dict(
        linker_info = LinkerInfo(**linker_info),
    )

    return [
        DefaultInfo(),
        ctx.attrs.base[CxxPlatformInfo],
        CxxToolchainInfo(**cxx_toolchain_info),
    ]

riscv_cxx_toolchain = rule(
    impl = _riscv_cxx_toolchain_impl,
    attrs = {
        "base": attrs.toolchain_dep(providers = [CxxPlatformInfo, CxxToolchainInfo]),
        "linker": attrs.string(),
        "linker_flags": attrs.list(attrs.arg(), default = []),
        "linker_type": attrs.enum(LinkerType.values()),
    },
    is_toolchain_rule = True,
)

def _riscv_rust_toolchain_impl(ctx):
    return [
        DefaultInfo(),
        RustToolchainInfo(
            allow_lints = ctx.attrs.allow_lints,
            clippy_driver = RunInfo(args = ["clippy-driver"]),
            clippy_toml = ctx.attrs.clippy_toml[DefaultInfo].default_outputs[0] if ctx.attrs.clippy_toml else None,
            compiler = RunInfo(args = ["rustc"]),
            default_edition = ctx.attrs.default_edition,
            panic_runtime = PanicRuntime("unwind"),
            deny_lints = ctx.attrs.deny_lints,
            doctests = ctx.attrs.doctests,
            nightly_features = ctx.attrs.nightly_features,
            report_unused_deps = ctx.attrs.report_unused_deps,
            rustc_binary_flags = ctx.attrs.rustc_binary_flags,
            rustc_flags = ctx.attrs.rustc_flags,
            rustc_target_triple = ctx.attrs.rustc_target_triple,
            rustc_test_flags = ctx.attrs.rustc_test_flags,
            rustdoc = RunInfo(args = ["rustdoc"]),
            rustdoc_flags = ctx.attrs.rustdoc_flags,
            warn_lints = ctx.attrs.warn_lints,
        ),
    ]

riscv_rust_toolchain = rule(
    impl = _riscv_rust_toolchain_impl,
    attrs = {
        "allow_lints": attrs.list(attrs.string(), default = []),
        "clippy_toml": attrs.option(attrs.dep(providers = [DefaultInfo]), default = None),
        "default_edition": attrs.option(attrs.string(), default = None),
        "deny_lints": attrs.list(attrs.string(), default = []),
        "doctests": attrs.bool(default = False),
        "nightly_features": attrs.bool(default = False),
        "report_unused_deps": attrs.bool(default = False),
        "rustc_binary_flags": attrs.list(attrs.string(), default = []),
        "rustc_flags": attrs.list(attrs.string(), default = []),
        "rustc_target_triple": attrs.string(default = "riscv64gc-unknown-linux-gnu"),
        "rustc_test_flags": attrs.list(attrs.string(), default = []),
        "rustdoc_flags": attrs.list(attrs.string(), default = []),
        "warn_lints": attrs.list(attrs.string(), default = []),
    },
    is_toolchain_rule = True,
)
