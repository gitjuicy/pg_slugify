FROM postgres:16
RUN apt-get update && apt-get upgrade -y

ENV build_deps build-essential libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev \
      libxml2-utils xsltproc ccache pkg-config curl libclang-dev postgresql-server-dev-16 ca-certificates git

RUN apt-get install -y --no-install-recommends $build_deps

WORKDIR /root

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal --default-toolchain nightly
ENV PATH="/root/.cargo/bin:${PATH}"

RUN cargo install --locked cargo-pgrx
RUN cargo pgrx init --pg15 $(which pg_config)

RUN git clone https://github.com/gitjuicy/pg_slugify.git && \
      cd pg_slugify && \
      cargo pgrx install

RUN rm -rf /root/pg_slugify && \
      apt-get clean && \
      apt-get autoremove -y $build_deps
