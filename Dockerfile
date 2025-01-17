FROM ubuntu:18.04 as downloader

RUN apt update &&\
    apt install -y git

#Fetch repo
RUN git clone https://github.com/eduardo010174/GSHADE.git &&\
    cd GSHADE/ &&\
    cd util/ &&\
    git clone https://github.com/eduardo010174/MIRACL.git

FROM ubuntu:18.04 as builder

RUN apt update &&\
    apt install -y \
        g++ \
        make \
        libgmp-dev \
        libssl1.0-dev

COPY --from=0 /GSHADE /GSHADE
WORKDIR /GSHADE

#Compile Miracl
RUN cd util/ &&\
    mkdir -p ./Miracl/ &&\
    find ./MIRACL/ -type f -exec cp ${PWD}/'{}' ${PWD}/Miracl/ \; &&\
    cd ./Miracl/ &&\
    bash linux64 &&\
    find . -type f -not -name '*.a' -not -name '*.h' -not -name '*.o' -not -name '.git*' | xargs rm

#Compile GSHADE
RUN make

FROM ubuntu:18.04 as runner

RUN apt update &&\
    apt install -y \
        libgmp10 \
        libssl1.0

COPY --from=1 /GSHADE/dst.exe /GSHADE/dst.exe
WORKDIR /GSHADE
