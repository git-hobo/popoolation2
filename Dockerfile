FROM debian:stable-slim

LABEL maintainer="<fabian.schweitzer@biologie.uni-freiburg.de>" \
      description="Container for PoPoolation2 and pipeline dependencies (Perl + R + bwa + samtools + Text::NSP)"

# Non-interactive apt
ENV DEBIAN_FRONTEND=noninteractive

# System Perl, R, bwa, samtools, Java, toolchain + cpanminus
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        perl \
        perl-doc \
        make \
        gcc \
        g++ \
        cpanminus \
        bwa \
        samtools \
        r-base-core \
        default-jre-headless \
        ca-certificates \
        less \
        dos2unix \
        && rm -rf /var/lib/apt/lists/*

# Install required Perl module for Fisher's exact test
# This pulls in Text::NSP and the Measures::2D::Fisher::twotailed submodule.
RUN cpanm --notest Text::NSP::Measures::2D::Fisher::twotailed

# Put the software under /opt
WORKDIR /opt/popoolation2
COPY . /opt/popoolation2

# Workaround for possible Windows line endings in scripts on Windows git clone.
RUN find /opt/popoolation2 -type f \( -name '*.pl' -o -name '*.pm' -o -name '*.sh' \) -exec dos2unix {} +

# Make all *.pl scripts executable and add aliases on PATH:
#   "fst-sliding.pl" and "fst-sliding", etc.
RUN chmod +x /opt/popoolation2/*.pl || true && \
    for f in /opt/popoolation2/*.pl; do \
        [ -f "$f" ] || continue; \
        bn="$(basename "$f")"; \
        base="${bn%.pl}"; \
        ln -s "/opt/popoolation2/$bn" "/usr/local/bin/$bn" || true; \
        ln -s "/opt/popoolation2/$bn" "/usr/local/bin/$base" || true; \
    done

# Also keep repo itself on PATH
ENV PATH="/opt/popoolation2:${PATH}"

# Default to interactive shell
ENTRYPOINT ["/bin/bash"]