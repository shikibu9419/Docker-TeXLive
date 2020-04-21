FROM ubuntu:19.10

LABEL maintainer="shikibu9419 <shikibu9419@gmail.com>"

ENV TL_VERSION 2019
ENV TL_PATH    /usr/local/texlive
ENV PATH       ${TL_PATH}/bin/x86_64-linux:/bin:${PATH}

WORKDIR /tmp

# Install required packages
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
    wget unzip ghostscript perl-modules-5.28 && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Install TeX Live
RUN mkdir install-tl-unx && \
    wget -qO- http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | \
      tar -xz -C ./install-tl-unx --strip-components=1 && \
    printf "%s\n" \
      "TEXDIR ${TL_PATH}" "selected_scheme scheme-full" "option_doc 0" "option_src 0" \
      > ./install-tl-unx/texlive.profile && \
    ./install-tl-unx/install-tl -profile ./install-tl-unx/texlive.profile && \
    rm -rf ./install-tl-unx

# Set up font and llmk
RUN cjk-gs-integrate --cleanup --force && \
    cjk-gs-integrate --force && \
    kanji-config-updmap-sys --jis2004 haranoaji && \
    luaotfload-tool -u -f && \
    wget -q -O /usr/local/bin/llmk https://raw.githubusercontent.com/wtsnjp/llmk/master/llmk.lua && \
    chmod +x /usr/local/bin/llmk

# Install jlisting
RUN wget -qO- https://osdn.net/projects/mytexpert/downloads/26068/jlisting.sty.bz2 | \
    bunzip2 > "${TL_PATH}/texmf-dist/tex/latex/listings/jlisting.sty"

RUN mktexlsr

VOLUME [/usr/local/texlive/2019/texmf-var/luatex-cache]

WORKDIR /workdir
