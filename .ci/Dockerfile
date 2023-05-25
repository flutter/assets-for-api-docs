# Last updated 05/25/2023 (to rebuild the docker image, update this timestamp)
# This is the hash for the Flutter 3.0.0 image.
FROM cirrusci/flutter@sha256:d99b1ba2602240a74722970b5c0cd704bbe60a7eba7557157c784f2f693c393f

RUN sudo apt-get update && \
    sudo apt-get upgrade --yes && \
    sudo apt-get install --yes gpg-agent && \
    sudo apt-get clean --yes

# This must occur after the install of gpg-agent
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add - && \
    sudo apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-12 main" && \
    sudo apt-get update && \
    sudo apt-get install --yes --allow-unauthenticated libffi7 libllvm12 libclang-cpp12 clang clang-format-12

RUN sudo apt-get install --yes cmake ninja-build pkg-config libgtk-3-dev && \
    sudo apt-get clean --yes

RUN sudo "$FLUTTER_HOME/bin/flutter" config --enable-linux-desktop --enable-windows-desktop --enable-macos-desktop
