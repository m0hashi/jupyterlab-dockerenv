#================================================================================
# Make conda base environment
#================================================================================
FROM ubuntu:20.04  as conda-base
SHELL ["/bin/bash", "-c"]

ENV TZ Asia/Tokyo
RUN apt-get update \
  && apt-get install -y tzdata \
  && rm -rf /var/lib/apt/lists/* \
  && echo "${TZ}" > /etc/timezone \
  && rm /etc/localtime \
  && ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
  && dpkg-reconfigure -f noninteractive tzdata \
  && apt-get clean

COPY ./files/apt-packagelist.txt .tmp/
RUN apt-get update --fix-missing && \
    apt-get install -y $(grep -vE "^\s*#" .tmp/apt-packagelist.txt  | tr "\n" " ") && \
    apt-get clean

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean

ARG UNAME
ARG GID
ARG UID 
ARG UPASSWD

#Add user
RUN echo ${UNAME} ${GID} && \
    groupadd  ${UNAME} -g ${GID} && \
    useradd -u ${UID} -g ${UNAME} -m ${UNAME} --create-home --shel /bin/bash && \
    usermod -aG sudo ${UNAME} && \
    echo "Set disable_coredump false" >> /etc/sudo.conf && \
    echo ${UNAME}:${UPASSWD} | chpasswd
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

ARG UNAME
#install jupyter lab extensions
#for  details, see -> https://qiita.com/canonrock16/items/d166c93087a4aafd2db4
RUN conda install -c conda-forge jupyterlab

RUN mkdir /home/${UNAME}/.tmp
COPY ./files/jupyterlab-extensions.txt /home/${UNAME}/.tmp/
RUN cat /home/${UNAME}/.tmp/jupyterlab-extensions.txt | tr '\n' ' ' >/home/${UNAME}/.tmp/tmplist && \
   jupyter labextension install `cat /home/${UNAME}/.tmp/tmplist`

#install ML library
COPY ./files/conda-requirements.txt ./files/pip-requirements.txt /home/${UNAME}/.tmp/
RUN conda install -c conda-forge --file /home/${UNAME}/.tmp/conda-requirements.txt && \
    conda clean --all && \
    pip install --no-cache-dir -r /home/${UNAME}/.tmp/conda-requirements.txt


#================================================================================
# Set startup configurations
#================================================================================
FROM jupyterlab-base

ARG UNAME

RUN mkdir ~/.local && \
    mkdir ~/workspace && \
    mkdir ~/.ssh && \
    mkdir ~/.kaggle && \
    mkdir ~/.aws

COPY ./files/docker-entrypoint.sh /home/${UNAME}/.local/bin/docker-entrypoint.sh

USER root
RUN chown ${UNAME}:${UNAME} /home/${UNAME}/.local/bin/docker-entrypoint.sh && \
    mkdir /var/run/sshd

