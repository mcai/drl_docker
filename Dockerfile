FROM nvidia/cuda:11.2.2-cudnn8-runtime-ubuntu20.04

# Use the bash shell instead of sh (default) for the following RUN commands
SHELL ["/bin/bash","-c"]

# Update package list
RUN apt-get update

# Install system packages
RUN apt-get install -y wget screen git build-essential

# Install cmake
RUN cd /opt && \
    wget https://github.com/Kitware/CMake/releases/download/v3.25.1/cmake-3.25.1-linux-x86_64.sh && \
    bash cmake-3.25.1-linux-x86_64.sh --skip-license --prefix=/usr/local && \
    rm cmake-3.25.1-linux-x86_64.sh && \
    rm -rf /opt/cmake-3.25.1-Linux-x86_64

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
    make -j$(nproc) && \
    make install && \
    cd /opt && \
    rm -rf CGAL-5.2.4 CGAL-5.2.4.tar.xz

# Install Anaconda
ENV CONDA_DIR /opt/conda
RUN wget https://repo.anaconda.com/archive/Anaconda3-2022.10-Linux-x86_64.sh && \
    bash Anaconda3-2022.10-Linux-x86_64.sh -b -p $CONDA_DIR && \
    rm Anaconda3-2022.10-Linux-x86_64.sh

# conda init bash on every bash shell
RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.bashrc

# conda init bash on every RUN command
ENV PATH $CONDA_DIR/bin:$PATH

# Create Conda environment "env" from the YAML file
COPY environment.yaml .
RUN conda env create -f environment.yaml

# conda activate "env" on every bash shell
RUN echo "conda activate env" >> ~/.bashrc

# conda activate "env" on every RUN command
RUN conda activate env

# Install scikit-geometry
RUN cd /opt && \
    git clone https://github.com/scikit-geometry/scikit-geometry.git && \
    cd /opt/scikit-geometry && \
    sed -i 's/CGAL_DEBUG=1/CGAL_DEBUG=0/g' setup.py && \
    python setup.py install

# Entry point
CMD ["/bin/bash"]
