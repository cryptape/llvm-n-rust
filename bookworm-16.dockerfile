FROM docker.io/buildpack-deps:bookworm as builder
MAINTAINER Xuejie Xiao <xxuejie@gmail.com>

RUN apt-get update && apt-get install -y cmake

RUN mkdir -p /tmp/llvm-project
WORKDIR /tmp/llvm-project
RUN curl -LO https://github.com/llvm/llvm-project/archive/llvmorg-16.0.6.tar.gz
# For local development, uncomment this(and comment the above line) to save the effort
# of downloading LLVM archives multiple times
# COPY llvmorg-16.0.6.tar.gz /tmp/llvm-project/llvmorg-16.0.6.tar.gz
RUN mkdir -p /llvm
RUN sha256sum llvmorg-16.0.6.tar.gz > /llvm/tarball_checksum.txt
RUN tar xzf llvmorg-16.0.6.tar.gz --strip-components=1 && rm llvmorg-16.0.6.tar.gz

RUN mkdir /tmp/llvm-project/clang-build
WORKDIR /tmp/llvm-project/clang-build
RUN cmake ../llvm \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/llvm \
  -DLLVM_ENABLE_PROJECTS="clang;lld" \
  -DLLVM_TARGETS_TO_BUILD="X86;AArch64;RISCV" \
  -DLLVM_LINK_LLVM_DYLIB=ON
RUN make -j$(nproc)
RUN make install

FROM docker.io/buildpack-deps:bookworm
MAINTAINER Xuejie Xiao <xxuejie@gmail.com>

RUN apt-get update && apt-get install -y cmake

COPY --from=builder /llvm /llvm
RUN find /llvm/bin -not -type d -exec ln -s {} {}-16 \;
ENV LLVM_HOME /llvm
ENV PATH "${PATH}:${LLVM_HOME}/bin"
CMD ["clang", "--version"]
