# Notes on creating a class server for the students

It is possible to use [JupyterHub](https://jupyter.org/hub) with Pluto to create
a server for the students saving them the hassle of installing Julia on their
computers.

I outline the steps here to document the procedure. For this, You need a
computer that will act as a server. This computer needs to have at least one
port open to the Internet, accessible to the students' computers. I will write
the documentation assuming that the server runs Ubuntu. It probably works for
other Linux flavors.

Obs: These instructions were inspired by other [instructions to create a Pluto
server from Maximilian
Koehler](https://www.maximiliankoehler.de/posts/pluto-server/).

## Steps to install the server with conda

1. Create users for each student. You may also want to create a common group for
   these students. For example, you can create the group `lcs` and the students'
   users are named `lcsXX` where `XX` is a double-digit integer. You also need a
   way to send the users their credentials (username and password).

1. To avoid each user installing packages in Julia you may create a user that
   will install a common package set. The trick is that this user should have a
   dir where only he can write and all can read where he will install the files.
   When needed it should set
   ```bash
   export GLOBAL_DEPOT_PATH=/usr/local/lib/julia/labcompsci
   export JULIA_DEPOT_PATH=$GLOBAL_DEPOT_PATH
   sudo mkdir -p $JULIA_DEPOT_PATH
   sudo chown pjssilva:pjssilva $JULIA_DEPOT_PATH
   ```
   Then he should install all the packages that will land in
   `$JULIA_DEPOT_PATH`. On the other hand the students should have something 
   like
   ```bash
   export GLOBAL_DEPOT_PATH=/usr/local/lib/julia/labcompsci
   export JULIA_DEPOT_PATH=~/.julia:$GLOBAL_DEPOT_PATH
   ```
   With these settings they will use the packages in `$GLOBAL_DEPOT_PATH` if
   they exist (in the right version). Otherwise, they will be able to install
   their files.

1. Create a separate conda environment for jupyterhub, believe this is good
   practice. As root, do
   ```bash
   conda create --yes --name jupyterhub python=3.11
   conda activate jupyterhub
   ```

1. **Optional**. I will want the same server to be used for Python, so I
   need to install extra packages from Anaconda. 
   ```bash
   conda install --yes anaconda
   ```

1. Now install JupyterHub using
   ```bash
   conda install --yes jupyter jupyterhub jupyter-server-proxy
   pip install git+https://github.com/fonsp/pluto-on-jupyterlab.git
   # Used to stop idle sessions
   conda install --yes -c conda-forge jupyterhub-idle-culler 
   # Used to limit resources allocated by each user
   pip install jupyterhub-systemdspawner
   ```
1. Copy JupyterHubs's configuration file `jupyterhub_config.py` to
   `/opt/conda/envs/jupyterhub/etc/jupyterhub`. Create the directory if needed.

1. After that you can test the jupyterhub server. It will accept a connection on
   port 8000 from a browser. You will need to login to access the server using a
   regular credential in the server machine.
   ```bash
   jupyterhub --config=/opt/conda/envs/jupyterhub/etc/jupyterhub/jupyterhub_config.py
   ```

1. Create a script to activate the conda environment and call jupyterhub copying
   the file `jupyterhub_driver.sh` to `/usr/local/bin`.

1. Now configure JupyterHub to install as a systemd daemon.
   ```bash
   mkdir /opt/conda/envs/jupyterhub/etc/systemd
   ```
   Copy the file `jupyterhub.service` in this new directory and link it using
   `ln -s` to `/etc/systemd/system/jupyterhub.service`.
   ```bash
   ln -s /opt/conda/envs/jupyterhub/etc/systemd/jupyterhub.service /etc/systemd/system/jupyterhub.service
   systemctl enable jupyterhub.service
   systemctl start jupyterhub.service 
   systemctl status jupyterhub.services
   ```
   This will start the service and print some information to see if it is
   working correctly.

1. Now install `caddy` to have a reverse proxy and https.
   ```bash
   sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
   sudo apt update
   sudo apt install caddy
   ```
   After that go to `/etc/caddy/Caddyfile` and change `:80` with the full
   qualified domain name of your server and restart `sudo systemctl restart
   caddy.service`. Point your browser to your server and see if https is
   working.

1. If https is working, edit again `/etc/caddy/Caddyfile` uncommenting the
   `ReverseProxy` line and changing the port `8000` which is the JupyterHub
   port. Reload the server page to see if it shows JupyterHub's login page using
   https.

1. Now install `ufw` if it is not installed yet and close port `80` letting only
   `443`(https) open.
   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw allow OpenSSH
   sudo ufw limit https
   sudo ufw show added
   sudo ufw enable
   ```
