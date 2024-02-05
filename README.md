# llvm-n-rust

A collection of docker images that lock the version of LLVM suite and Rust, so we can do reproducible build for CKB smart contracts.

Notice that docker is one way of doing reproducible build, it is not THE way to do it, nor likely the best way to do it. It's just one practical solution given the efforst we are willing to pull in now. In the future, we might switch to other ways(such as chroot based solutions) to provide more reproducible guarentees.
