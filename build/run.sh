#!/bin/bash
nvidia-smi 
if [[ $? -ne 0 ]]; then exit; fi
cd /root && git clone --recurse-submodules https://github.com/facebookresearch/xformers.git
cd xformers && pip wheel .
cp xformers*.whl /output