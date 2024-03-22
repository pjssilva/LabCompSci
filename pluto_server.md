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

2. To avoid each user installing packages in Julia you may create a user that
   will install a common package set. The trick is that this user should have a
   dir where only he can write and all can read where he will install the files.
   When needed it should set
   ```bash
   export GLOBAL_DEPOT_PATH=/usr/local/lib/julia/labcompsci
   export JULIA_DEPOT_PATH=$GLOBAL_DEPOT_PATH
   ```
   Then he should install all the packages that will land in
   `$JULIA_DEPOT_PATH`. On the other hand the students should have something 
   like
   ```bash
   export GLOBAL_DEPOT_PATH=/usr/local/lib/julia/labcompsci
   export JULIA_DEPOT_PATH=~/.julia:$GLOBAL_DEPOT_PATH
   ```
   With these they will use the packages in `$GLOBAL_DEPOT_PATH` if they exist
   (in the right version). Otherwise, they will be able to install their own
   files.

3. Now first install JupyterHaub using
   ```bash
   conda install --yes jupyter jupyterhub jupyter-server-proxy
   pip install git+https://github.com/fonsp/pluto-on-jupyterlab.git
   ```
4. Depois disso, já dá para testar o servidor rodando `jupyterhub`. Ele aceitará
   conxeões na port 8000 a partir de um browser. Note que você preisa se logar
   para acessar o servidor e a autenticação é feita usando as credenciais da
   máquna.

## Todo

1. Ajustar a configuração do JupyterHub para export o `JULIA_DEPOT_PATH`.
1. Veririficar se o JupyterHub pode usar credenciais NIS.
2. Instalar o firewall na máquina e deixar abertas apenas as portas 22 para ssh.
3. Instalar um proxy reverso baseado em caddy para ter o https funcionando.
4. Abrir a porta 80 para acessar o proxy reverso de fora.


    

