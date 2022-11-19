FROM nvidia/cuda:11.6.0-devel-ubuntu20.04 AS base
# set mirror for speedup apt
RUN sed -i 's/archive.ubuntu.com/mirror.xtom.com.hk/g' /etc/apt/sources.list 
# install python and git
RUN apt update && apt install -y python3 python3-pip git
# install pytorch
RUN pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu116
WORKDIR /content

FROM base as build
COPY ./build/run.sh /root/
RUN chmod 755 /root/run.sh
CMD bash -c /root/run.sh

FROM base as finish
COPY ./build/output/ /root/
RUN pip install git+https://github.com/CCRcmcpe/diffusers \
    git+https://github.com/wandb/wandb accelerate==0.12.0 \
    transformers ftfy bitsandbytes omegaconf einops protobuf==3.20 \
    pytorch_lightning && pip install -U --pre triton
RUN cd /root && pip install *.whl
RUN ln -s /usr/bin/python3 /usr/bin/python

FROM finish as cli
CMD echo done, please run command \"docker exec -it $(hostname) bash\" to run a shell && bash

FROM finish as notebook
RUN pip install notebook
CMD jupyter notebook --allow-root --ip='*' --NotebookApp.token='' --NotebookApp.password='' /content/
EXPOSE 8888