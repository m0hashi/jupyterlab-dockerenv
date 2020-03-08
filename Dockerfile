#================================================================================
# Make conda base environment
#================================================================================
FROM ubuntu:18.04  as conda-base

RUN apt-get update --fix-missing && \
    apt-get install -y wget && \
    apt-get clean

# install anaconda
ENV PATH /opt/conda/bin:$PATH
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

#================================================================================
# Make conda jupyterlab environment
#================================================================================
FROM conda-base as jupyterlab-base
RUN apt-get update --fix-missing && \
    apt-get install -y  bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 \
            git mercurial subversion openssh-server && \
    apt-get clean



#install jupyter lab extensions
#for  details, see -> https://qiita.com/canonrock16/items/d166c93087a4aafd2db4
RUN conda install -c conda-forge jupyterlab 
RUN conda install -c conda-forge nodejs
RUN jupyter labextension install \
  @lckr/jupyterlab_variableinspector \
  @jupyterlab/toc \
  jupyterlab_vim \
  @jupyterlab/git

#install ML library
RUN conda install -c conda-forge \
  lightgbm \
  catboost

# add user
#RUN adduser kaggle --disabled-password
#ARG user=kaggle
#ARG passwd=passwd
#RUN echo "${user}:${passwd}" | chpasswd

#================================================================================
# Set startup configurations
#================================================================================
FROM jupyterlab-base

#ssh-login setting
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

WORKDIR /workspace
COPY ./files/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT [ "bash", "/usr/local/bin/docker-entrypoint.sh" ]
#CMD ["jupyter-lab","--port","8888","--ip","0.0.0.0", "--allow-root" , "--notebook-dir=/workspace", "--NotebookApp.token=''"]





