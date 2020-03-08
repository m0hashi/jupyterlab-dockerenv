#!/bin/bash
/usr/sbin/sshd -D &
jupyter-lab --port 8888 --ip 0.0.0.0 --allow-root --notebook-dir=/workspace \
--NotebookApp.token='' --no-browser
