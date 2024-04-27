#!/bin/bash
source /opt/conda/etc/profile.d/conda.sh 
conda activate jupyterhub
jupyterhub --config=/opt/conda/envs/jupyterhub/etc/jupyterhub/jupyterhub_config.py
