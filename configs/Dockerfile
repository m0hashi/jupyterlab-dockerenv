#================================================================================
# Make conda base environment
#================================================================================
FROM ubuntu:20.04  as conda-base
SHELL ["/bin/bash", "-c"]

ARG UNAME
ARG GID
ARG UID
ARG UPASSWD

ENV TZ Asia/Tokyo
RUN apt-get update \
  && apt-get install -y tzdata \
  && rm -rf /var/lib/apt/lists/* \
  && echo "${TZ}" > /etc/timezone \
  && rm /etc/localtime \
  && ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
  && dpkg-reconfigure -f noninteractive tzdata

RUN apt-get update --fix-missing && \
    apt-get install -y sudo wget curl  bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 \
            git mercurial subversion openssh-server && \
    apt-get clean

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs 

#Add user
RUN echo ${UNAME} ${GID}
RUN groupadd  ${UNAME} -g ${GID}
RUN useradd -u ${UID} -g ${UNAME} -m ${UNAME} --create-home --shel /bin/bash
RUN usermod -aG sudo ${UNAME} && \
    echo "Set disable_coredump false" >> /etc/sudo.conf
RUN echo ${UNAME}:${UPASSWD} | chpasswd
USER ${UNAME}
WORKDIR /home/${UNAME}

#Install Anaconda
ENV PATH ~/.conda/bin:$PATH
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh -O ~/anaconda.sh && \
    bash ~/anaconda.sh -b -p ~/.conda && \
    rm ~/anaconda.sh && \
    echo "PATH=~/.conda/bin/:$PATH" >> ~/.bashrc && \
    echo ". ~/.conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find ~/.conda/ -follow -type f -name '*.a' -delete && \
    find ~/.conda/ -follow -type f -name '*.js.map' -delete && \
    ~/.conda/bin/conda clean -afy

#================================================================================
# Make conda jupyterlab environment
#================================================================================
FROM conda-base as jupyterlab-base

#install jupyter lab extensions
#for  details, see -> https://qiita.com/canonrock16/items/d166c93087a4aafd2db4
#RUN conda install -c conda-forge jupyterlab=1.2.0 
RUN conda install -c conda-forge jupyterlab
RUN jupyter labextension install \
  @lckr/jupyterlab_variableinspector \
  @jupyterlab/toc \
  jupyterlab_vim \
  @jupyterlab/git

#install ML library
RUN conda install -c conda-forge \
  lightgbm catboost

#================================================================================
# Set startup configurations
#================================================================================
FROM jupyterlab-base

ARG UNAME

RUN mkdir ~/.local
RUN mkdir ~/workspace
RUN mkdir ~/.ssh
COPY ./files/docker-entrypoint.sh /home/${UNAME}/.local/bin/docker-entrypoint.sh

USER root
RUN chown ${UNAME}:${UNAME} /home/${UNAME}/.local/bin/docker-entrypoint.sh
RUN mkdir /var/run/sshd

