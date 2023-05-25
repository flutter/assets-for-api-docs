# Last updated 10/01/2021 (to rebuild the docker image, update this timestamp)
FROM cirrusci/flutter:dev

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
