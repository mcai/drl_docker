from nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu20.04

# Install system packages
RUN apt-get update && \
    apt-get install -y wget screen git build-essential

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm Miniconda3-latest-Linux-x86_64.sh

# Add conda to PATH
ENV PATH /opt/conda/bin:$PATH

# Update conda
RUN conda update -n base -c defaults conda

# Create Conda environment from the YAML file
COPY environment.yaml .
RUN conda env create -f environment.yaml

# Override default shell and use bash
SHELL ["conda", "run", "-n", "env", "/bin/bash", "-c"]

# Install cmake
RUN cd /opt && \
    wget https://github.com/Kitware/CMake/releases/download/v3.25.1/cmake-3.25.1-linux-x86_64.sh && \
    bash cmake-3.25.1-linux-x86_64.sh --skip-license --prefix=/usr/local && \
    rm cmake-3.25.1-linux-x86_64.sh

# Configure timezone as UTC
RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Install CGAL dependencies
RUN apt-get install -y libgmp-dev libmpfr-dev libboost-all-dev libgl1-mesa-dev libglu1-mesa-dev

# Install CGAL 5.2.4
RUN cd /opt && \
    wget https://github.com/CGAL/cgal/releases/download/v5.2.4/CGAL-5.2.4.tar.xz && \
    tar -xf CGAL-5.2.4.tar.xz && \
    cd CGAL-5.2.4 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j8 && \
    make install

# Install scikit-geometry
RUN cd /opt && \
    git clone https://github.com/scikit-geometry/scikit-geometry.git && \
    cd /opt/scikit-geometry && \
    sed -i 's/CGAL_DEBUG=1/CGAL_DEBUG=0/g' setup.py && \
    python setup.py install
