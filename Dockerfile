# 使用更轻量的Miniconda镜像（比Anaconda节省2GB+空间）
FROM continuumio/miniconda3:4.12.0

# 合并APT操作（减少镜像层数）
RUN sed -i 's/main/main contrib non-free/' /etc/apt/sources.list && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    zlib1g-dev libbz2-dev \
    libcurl4-gnutls-dev libssl-dev \
    openjdk-17-jdk-headless \
    libgsl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 合并Python环境配置（避免重复创建环境）
#RUN conda create -n bowtie -y -c bioconda \
RUN conda install -y -c bioconda python=3.7.11 \
    bowtie bowtie2 samtools && \
    conda clean --all -y

# 合并Python包安装（利用缓存机制）
RUN /opt/conda/bin/pip install --no-cache-dir methylpy cutadapt

# 修复路径问题（原libgsl链接路径错误）
RUN ln -sf /usr/lib/x86_64-linux-gnu/libgsl.so.25 /lib/libgsl.so.0

# 安全加固（非root用户运行）
RUN useradd -r -m -U -d /app -s /bin/false appuser
WORKDIR /app
USER appuser
