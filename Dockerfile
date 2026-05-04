FROM debian:stable-slim

ARG VCS_REF

LABEL org.opencontainers.image.title="Popoolation2 analysis container"
LABEL org.opencontainers.image.description="Containerized Popoolation2 environment used for Pool-Seq. analysis in the Polistes cryptic species project"
LABEL org.opencontainers.image.authors="Fabian Schweitzer <fabian.schweitzer@biologie.uni-freiburg.de>"
LABEL org.opencontainers.image.source="https://github.com/git-hobo/popoolation2"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.revision=$VCS_REF
LABEL org.opencontainers.image.created="2026-05-04"
LABEL org.opencontainers.image.licenses="BSD 2-Clause"

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
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
        trimmomatic \
        default-jdk \
        ca-certificates \
        less \
        dos2unix \
        file \
        bsdextrautils \
        xxd \
        && rm -rf /var/lib/apt/lists/*

# Install required Perl library
RUN cpanm --notest Text::NSP::Measures::2D::Fisher::twotailed

# Create directory
RUN mkdir -p /opt/popoolation2

# Copy Perl scripts from root and subdirectories
COPY cmh-test.pl \
     create-genewise-sync.pl \
     fisher-test.pl \
     fst-sliding.pl \
     mpileup2sync.pl \
     snp-frequency-diff.pl \
     subsample-synchronized.pl \
     synchronize-pileup.pl \
     export/cmh2gwas.pl \
     export/compute-max-coverage.pl \
     export/pwc2igv.pl \
     export/subsample_sync2GenePop.pl \
     export/subsample_sync2fasta.pl \
     indel_filtering/filter-sync-by-gtf.pl \
     indel_filtering/identify-indel-regions.pl \
     /opt/popoolation2/

# Copy Modules directory
COPY Modules/ /opt/popoolation2/Modules/

# Copy export scripts
COPY export/ /opt/popoolation2/export/

# Copy the Java jar explicitly
COPY mpileup2sync.jar /opt/popoolation2/mpileup2sync.jar

#
# Convert ONLY text files if downloaded on Windows.
#
RUN find /opt/popoolation2 -type f \
        \( -name "*.pl" -o -name "*.pm" -o -name "*.sh" \) \
        -exec dos2unix {} +

# Make scripts executable and add both .pl and alias without .pl
RUN chmod +x /opt/popoolation2/*.pl && \
    for f in /opt/popoolation2/*.pl; do \
        base=$(basename "$f" .pl); \
        ln -sf "/opt/popoolation2/$base.pl" "/usr/local/bin/$base"; \
        ln -sf "/opt/popoolation2/$base.pl" "/usr/local/bin/$base.pl"; \
    done

# Add /opt/popoolation2 to PATH
ENV PATH="/opt/popoolation2:${PATH}"

#
# Add Java logging configuration
#
COPY logging.properties /opt/popoolation2/logging.properties

# Enable Java logging system-wide
ENV JAVA_TOOL_OPTIONS="-Djava.util.logging.config.file=/opt/popoolation2/logging.properties"

CMD ["/bin/bash"]
