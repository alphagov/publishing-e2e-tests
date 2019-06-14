FROM ruby:2.6.1

ARG GUIX_VER=1.0.1
ARG GPG_KEYS=3CE464558A84FDC69DB40CFB090B11993D9AEBB5
ARG REPOBASE=https://ftp.gnu.org/gnu/guix
ARG TARFILE=guix-binary-$GUIX_VER.x86_64-linux.tar.xz
ARG NUM_BUILDERS=10

ENV BUILDDIR=/tmp/guix
ENV BUILDERS_GROUP=guixbuilder
ENV BUILDERS_USERS=guixbuilder
ENV PATH="/root/.guix-profile/bin:/root/.config/guix/current/bin:$PATH"

# Add build group
RUN groupadd --system $BUILDERS_GROUP && \
    for i in $(seq -w 1 $NUM_BUILDERS); do \
        useradd -g $BUILDERS_GROUP -G $BUILDERS_GROUP           \
            -d /var/empty -s "$(command -v nologin)"    \
            -c "Guix build user $i" --system    \
            "$BUILDERS_USERS$i"; \
    done

RUN mkdir ~/.gnupg
RUN echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf

# Ensure GPG keys and deps are present
RUN gpg --keyserver pool.sks-keyservers.net \
        --recv-keys $GPG_KEYS

# Ensure build directory is present
WORKDIR $BUILDDIR

# Download the distribution, verify it, and extract it
RUN wget $REPOBASE/$TARFILE && \
    wget $REPOBASE/$TARFILE.sig && \
    gpg --verify $TARFILE.sig && \
    tar -xf $TARFILE && \
    rm -f $TARFILE $TARFILE.sig

# Install the files
RUN mv $BUILDDIR/var/guix /var/ && \
    mv $BUILDDIR/gnu / && \
    rm -rf $BUILDDIR

RUN ln -s /var/guix/profiles/per-user/root/current-guix/bin/guix /usr/local/bin && \
    ln -s /var/guix/profiles/per-user/root/current-guix/bin/guix-daemon /usr/local/bin && \
    mkdir -p ~root/.config/guix && \
    ln -sf /var/guix/profiles/per-user/root/current-guix ~root/.config/guix/current

# Authorize substitutes
RUN guix archive --authorize < ~root/.config/guix/current/share/guix/ci.guix.gnu.org.pub
