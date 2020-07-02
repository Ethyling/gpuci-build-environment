ARG FROM_IMAGE=gpuci/miniconda-cuda
ARG CUDA_VER=10.2
ARG LINUX_VER=ubuntu18.04
FROM ${FROM_IMAGE}:${CUDA_VER}-devel-${LINUX_VER}

# Required arguments
ARG RAPIDS_CHANNEL=rapidsai-nightly
ARG RAPIDS_VER=0.15
ARG PYTHON_VER=3.6

# Optional arguments
ARG BUILD_STACK_VER=7.5.0
ARG CCACHE_VERSION=master
ARG PARALLEL_LEVEL=16
ARG CMAKE_VERSION=3.17.2

# Capture argument used for FROM
ARG CUDA_VER

# Update environment for gcc/g++ builds
ENV CC=/usr/bin/gcc
ENV CXX=/usr/bin/g++
ENV CUDAHOSTCXX=/usr/bin/g++
ENV CUDA_HOME=/usr/local/cuda
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib

# Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

# Add a condarc for channels and override settings
RUN if [ "${RAPIDS_CHANNEL}" == "rapidsai" ] ; then \
      echo -e "\
ssl_verify: False \n\
channels: \n\
  - rapidsai \n\
  - conda-forge \n\
  - nvidia \n\
  - defaults \n" > /conda/.condarc \
      && cat /conda/.condarc ; \
    else \
      echo -e "\
ssl_verify: False \n\
channels: \n\
  - rapidsai \n\
  - rapidsai-nightly \n\
  - conda-forge \n\
  - nvidia \n\
  - defaults \n" > /conda/.condarc \
      && cat /conda/.condarc ; \
    fi

# Install gcc7 - 7.5.0 to bring build stack in line with conda-forge
RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
    && apt-get update \
    && apt-get install -y gcc-7 g++-7 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 7 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 7 \
    && update-alternatives --set gcc /usr/bin/gcc-7 \
    && update-alternatives --set g++ /usr/bin/g++-7 \
    && gcc --version \
    && g++ --version

# Update and add pkgs for gpuci builds
RUN apt-get update -y --fix-missing \
    && apt-get -qq install apt-utils -y --no-install-recommends \
    && apt-get install -y \
      jq \
      libnuma1 \
      libnuma-dev \
      screen \
      tzdata \
      vim \
      libssl-dev libcurl4-openssl-dev zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

<<<<<<< HEAD
# # Install latest awscli
# RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
#     && unzip awscliv2.zip \
#     && ./aws/install \
#     && rm -rf ./aws ./awscliv2.zip

# # Add core tools to base env
# RUN source activate base \
#     && conda install -y --override-channels -c gpuci gpuci-tools \
#     && gpuci_retry conda install -y \
#       anaconda-client \
#       codecov

# # Create `rapids` conda env and make default
# RUN source activate base \
#     && gpuci_retry conda create --no-default-packages --override-channels -n rapids \
#       -c nvidia \
#       -c conda-forge \
#       -c defaults \
#       nomkl \
#       cudatoolkit=${CUDA_VER} \
#       git \
#       libgcc-ng=${BUILD_STACK_VER} \
#       libstdcxx-ng=${BUILD_STACK_VER} \
#       python=${PYTHON_VER} \
#     && sed -i 's/conda activate base/conda activate rapids/g' ~/.bashrc

# # Create symlink for old scripts expecting `gdf` conda env
# RUN ln -s /opt/conda/envs/rapids /opt/conda/envs/gdf

# # Install build/doc/notebook env meta-pkgs
# #
# # Once installed remove the meta-pkg so dependencies can be freely updated &
# # the meta-pkg can be installed again with updates
# RUN gpuci_retry conda install -y -n rapids --freeze-installed \
#       rapids-build-env=${RAPIDS_VER} \
#       rapids-doc-env=${RAPIDS_VER} \
#       rapids-notebook-env=${RAPIDS_VER} \
#     && conda remove -y -n rapids --force-remove \
#       rapids-build-env=${RAPIDS_VER} \
#       rapids-doc-env=${RAPIDS_VER} \
#       rapids-notebook-env=${RAPIDS_VER}

RUN git clone https://github.com/ccache/ccache.git /tmp/ccache && cd /tmp/ccache \
 && git checkout -b rapids-compose-tmp b1fcfbca224b2af5b6499794edd8615dbc3dc7b5 \
 && ./autogen.sh \
 && ./configure --disable-man --with-libb2-from-internet --with-libzstd-from-internet\
 && make install -j \
 && cd / \
 && rm -rf /tmp/ccache-${CCACHE_VERSION}* \
 && mkdir -p /ccache

#  # Install CMake
# RUN curl -fsSLO --compressed "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.tar.gz" \
#  && tar -xvzf cmake-$CMAKE_VERSION.tar.gz && cd cmake-$CMAKE_VERSION \
#  && ./bootstrap --system-curl --parallel=${PARALLEL_LEVEL} && make install -j${PARALLEL_LEVEL} \
#  && cd - && rm -rf ./cmake-$CMAKE_VERSION ./cmake-$CMAKE_VERSION.tar.gz \
#  # Install ccache
#  && git clone https://github.com/ccache/ccache.git /tmp/ccache && cd /tmp/ccache \
#  && git checkout -b rapids-compose-tmp e071bcfd37dfb02b4f1fa4b45fff8feb10d1cbd2 \
#  && mkdir -p /tmp/ccache/build && cd /tmp/ccache/build \
#  && cmake \
#     -DENABLE_TESTING=OFF \
#     -DUSE_LIBB2_FROM_INTERNET=ON \
#     -DUSE_LIBZSTD_FROM_INTERNET=ON .. \
#  && make ccache -j${PARALLEL_LEVEL} && make install && cd / && rm -rf ./ccache-${CCACHE_VERSION}*
=======
# Install latest awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf ./aws ./awscliv2.zip

# Add core tools to base env
RUN source activate base \
    && conda install -y --override-channels -c gpuci gpuci-tools \
    && gpuci_retry conda install -y \
      anaconda-client \
      codecov

# Create `rapids` conda env and make default
RUN source activate base \
    && gpuci_retry conda create --no-default-packages --override-channels -n rapids \
      -c nvidia \
      -c conda-forge \
      -c defaults \
      nomkl \
      cudatoolkit=${CUDA_VER} \
      git \
      libgcc-ng=${BUILD_STACK_VER} \
      libstdcxx-ng=${BUILD_STACK_VER} \
      python=${PYTHON_VER} \
    && sed -i 's/conda activate base/conda activate rapids/g' ~/.bashrc

# Create symlink for old scripts expecting `gdf` conda env
RUN ln -s /opt/conda/envs/rapids /opt/conda/envs/gdf

# Install build/doc/notebook env meta-pkgs
#
# Once installed remove the meta-pkg so dependencies can be freely updated &
# the meta-pkg can be installed again with updates
RUN gpuci_retry conda install -y -n rapids --freeze-installed \
      rapids-build-env=${RAPIDS_VER} \
      rapids-doc-env=${RAPIDS_VER} \
      rapids-notebook-env=${RAPIDS_VER} \
    && conda remove -y -n rapids --force-remove \
      rapids-build-env=${RAPIDS_VER} \
      rapids-doc-env=${RAPIDS_VER} \
      rapids-notebook-env=${RAPIDS_VER}

 # Install CMake
RUN curl -fsSLO --compressed "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.tar.gz" \
 && tar -xvzf cmake-$CMAKE_VERSION.tar.gz && cd cmake-$CMAKE_VERSION \
 && ./bootstrap --system-curl --parallel=${PARALLEL_LEVEL} && make install -j${PARALLEL_LEVEL} \
 && cd - && rm -rf ./cmake-$CMAKE_VERSION ./cmake-$CMAKE_VERSION.tar.gz \
 # Install ccache from specific commit in ccache's master branch
 && git clone https://github.com/ccache/ccache.git /tmp/ccache && cd /tmp/ccache \
 && git checkout -b rapids-compose-tmp e071bcfd37dfb02b4f1fa4b45fff8feb10d1cbd2 \
 && mkdir -p /tmp/ccache/build && cd /tmp/ccache/build \
 && cmake \
    -DENABLE_TESTING=OFF \
    -DUSE_LIBB2_FROM_INTERNET=ON \
    -DUSE_LIBZSTD_FROM_INTERNET=ON .. \
 && make ccache -j${PARALLEL_LEVEL} && make install && cd / && rm -rf ./ccache-${CCACHE_VERSION}*
>>>>>>> 057a2fc30cbe1164aadad01257f7cbb691737170

# Setup ccache env vars
ENV CCACHE_NOHASHDIR=
ENV CCACHE_DIR="/ccache"
ENV CCACHE_COMPILERCHECK="%compiler% --version"

# Uncomment these env vars to force ccache to be enabled by default
ENV CC="/usr/local/bin/gcc"
ENV CXX="/usr/local/bin/g++"
ENV NVCC="/usr/local/bin/nvcc"
ENV CUDAHOSTCXX="/usr/local/bin/g++"
RUN ln -s "$(which ccache)" "/usr/local/bin/gcc" \
    && ln -s "$(which ccache)" "/usr/local/bin/g++" \
    && ln -s "$(which ccache)" "/usr/local/bin/nvcc"

# Clean up pkgs to reduce image size and chmod for all users
RUN conda clean -afy \
    && chmod -R ugo+w /opt/conda

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
