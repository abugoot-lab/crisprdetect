# Set the base image to Ubuntu
#FROM ubuntu:14.04
#FROM biocontainers/clustalw:v2.1lgpl-6-deb_cv1
FROM chrishah/ncbi-blast:v2.6.0

#RUN apt-get -m update && apt-get install -y wget tar curl ncbi-blast+

#RUN apt-get update && apt-get -y upgrade && apt-get install -y build-essential perl-doc ncbi-blast+ && \
#	apt-get clean && apt-get purge && \
#       rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#RUN apt-get update && apt-get upgrade -y && useradd -ms /bin/bash luser && printf "#!/bin/bash\nexport DEBIAN_FRONTEND=noninteractive\napt-get install -y tzdata\nln -fs /usr/share/zoneinfo/Australia/Brisbane /etc/localtime\ndpkg-reconfigure --frontend noninteractive tzdata\n" >tzinst && chmod 700 tzinst && ./tzinst && rm -f tzinst && apt-get install -y clustalw && apt-get clean

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get install -y software-properties-common -y apt-transport-https
RUN apt-add-repository multiverse
RUN add-apt-repository restricted
RUN apt-get update 

RUN apt-get install -y \
    cpanminus \
    clustalw


RUN cpan Parallel::ForkManager


RUN apt update && \
    apt install --yes \
	wget \
	build-essential && \
    apt autoclean && \
    rm -rf /var/lib/apt/lists/* /var/log/dpkg.log

WORKDIR /opt

RUN wget http://search.cpan.org/CPAN/authors/id/Y/YA/YANICK/Parallel-ForkManager-1.19.tar.gz \
    && tar xvzf Parallel-ForkManager-1.19.tar.gz \
    && cd Parallel-ForkManager-1.19 \
    && perl Makefile.PL && make test && make install

RUN wget -O - wget https://github.com/weizhongli/cdhit/releases/download/V4.6.8/cd-hit-v4.6.8-2017-1208-source.tar.gz | \
    tar xzf - && \
    ln -s cd-hit-v4.6.8-2017-1208 cd-hit && \
    cd cd-hit && \
    make && \
    cd cd-hit-auxtools/ && \
    make

ENV PATH=/opt/cd-hit/:/opt/cd-hit/cd-hit-auxtools/:${PATH}

RUN apt-get -qq update && apt-get -y upgrade && \
	apt-get install -y emboss=6.6.0+dfsg-6build1

RUN apt-get update
RUN apt-get install -y software-properties-common

RUN wget https://www.tbi.univie.ac.at/RNA/download/sourcecode/2_4_x/ViennaRNA-2.4.14.tar.gz \
    && tar -zxvf ViennaRNA-2.4.14.tar.gz \
    && cd ViennaRNA-2.4.14 \ 
    && ./configure --prefix=/opt/ViennaRNA \
    && make install

#RUN apt-add-repository -y ppa:j-4/vienna-rna \
# && apt-get --quiet update \
# && apt-get -qqy install \
#    vienna-rna \
# && apt-get clean \
# && apt-get purge 

COPY CRISPRDetect_2.4 /opt/CRISPRDetect_2.4

ENV PATH="/opt/CRISPRDetect_2.4:${PATH}"
ENV PATH="/opt/ViennaRNA/bin:${PATH}"

WORKDIR /opt/CRISPRDetect_2.4/

# by default /bin/bash is executed
CMD ["/bin/bash"]