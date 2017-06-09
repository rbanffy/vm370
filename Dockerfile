FROM ubuntu:latest

RUN apt update && \
        apt install -y hercules wget unzip && \
        wget http://www.smrcc.org.uk/members/g4ugm/vm-370/vm370sixpack-1_2.zip && \
        unzip vm370sixpack-1_2.zip && \
        mv disks Disks && \
        mv Disks/shadows Disks/Shadows && \
        rm -rf /var/lib/apt/lists/* 3270 vm370sixpack-1_2.zip

EXPOSE 3270

CMD ["hercules", "-f", "sixpack.conf"]
