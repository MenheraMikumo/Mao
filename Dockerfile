FROM ubuntu:16.04
MAINTAINER Menhera.Mikumo@gmail.com
COPY ./bin /bin
RUN apt-get update && apt-get install -y wget bzip2 libfindbin-libs-perl fastqc zip unzip
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && bash ~/miniconda.sh -b -p $HOME/miniconda && export PATH="$HOME/miniconda/bin:$PATH"
RUN $HOME/miniconda/bin/pip install pipenv
