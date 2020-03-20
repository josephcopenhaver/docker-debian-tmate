FROM debian:10.0

# install user utilities
RUN if ! ( command -v bash && command -v curl && command -v tar && command -v gzip && command -v nc && command -v vim && command -v tmux ) then \
        export DEBIAN_FRONTEND=noninteractive ; \
        apt-get update \
        && apt-get install -y \
            bash \
            curl \
            tar \
            gzip \
            netcat \
            vim \
            tmux \
        && rm -rf /var/lib/apt/lists/* \
        ; \
    fi

# install s6 overlay so we can run multiple services in the container
ENV S6_OVERLAY_VERSION v1.21.8.0

RUN curl -fsSL \
        https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz | \
        tar zxvf - -C /

# install open-ssh, locale-gen, screen, and set language to utf8
# required by: tmate
RUN if ! ( command -v ssh-keygen && command -v locale-gen && command -v screen && command -v grep && command -v awk && command -v ps && command -v kill ) then \
        export DEBIAN_FRONTEND=noninteractive ; \
        apt-get update \
        && apt-get install -y \
            openssh-server \
            locales \
            screen \
            grep \
            gawk \
            procps \
        && rm -rf /var/lib/apt/lists/* \
        ; \
    fi ; \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen

# ensure utf8 env variables
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# install tmate
ENV TMATE_VERSION 2.2.1
RUN mkdir -p /tmp/tmate/ \
    && curl -fsSL https://github.com/tmate-io/tmate/releases/download/${TMATE_VERSION}/tmate-${TMATE_VERSION}-static-linux-amd64.tar.gz | \
        tar zxvf - -C /tmp/tmate/ \
    && chmod a+x /tmp/tmate/tmate-${TMATE_VERSION}-static-linux-amd64/tmate \
    && mv /tmp/tmate/tmate-${TMATE_VERSION}-static-linux-amd64/tmate /usr/bin/ \
    && rm -rf /tmp/tmate

# enable s6 services
COPY ./docker/root/ /

ENTRYPOINT ["/init"]
