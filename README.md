# Docker image for Jupyter lab
This docker image creates an ssh-connectable Jupyter Lab server on a workstation.
It is based on anaconda.

## Build 
After you have cloned this repository, run the following commands, and then the built container will start.

```sh
#Create .env in the current directory
#This file specifies the ports and password for the user in docker container.
./setDotenv.sh 
#Build image
docker-compose up --build
```
If you want to change the packages installed during the build, change the contents of the following files in the ./config/files directory.


- apt-packagelist.txt 

  add the package names installed with the `apt-get`.  

- conda-requirements.txt

  add the package names installed with the `conda install -c conda-force`.  

- pip-requirements.txt

  add the package names installed with the `pip install `.  

- jupyterlab-extensions.txt

  add the package names installed with the `jupyter labextension install`.  


## After build
You can access the jupyter lab via a browser and make an SSH connection to the container.
The default jupyter lab port is set to 8888 and the ssh port is set to 11111.

The user in the docker container is configured to have the same name, UID, and GID as the user who ran the build on the host.
The default password is password.

```
ssh yourname@localhost -p 11111
#enter your password
```

## Shared volumes

As described in the volume tag in docker-compose.yml, the container shares some directories with the host.
The default is the followings.
- ./workspace 
- ~/.ssh
- ~/.kaggle

So, your work in jupyter can be shared via workspace, and if your configured, you can connect to github or kaggle from inside the container without ssk-key copy paste.