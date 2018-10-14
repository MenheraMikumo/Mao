FROM continuumio/miniconda:4.5.4
MAINTAINER Menhera.Mikumo@gmail.com
LABEL description="Docker image containing all requirements for alignments"
COPY environment.yml /
RUN apt-get update && apt-get install -y procps && apt-get clean -y
RUN conda install conda=4.5.11
RUN conda env create -f /environment.yml && conda clean -a
ENV PATH /opt/conda/envs/nf-addons-align/bin:$PATH

