FROM debian:stable-slim

RUN apt update && \
        apt dist-upgrade -y && \
        apt install -y --no-install-recommends hercules wget unzip && \
        wget http://www.smrcc.org.uk/members/g4ugm/vm-370/vm370sixpack-1_3.zip && \
        unzip vm370sixpack-1_3.zip && \
        apt purge -y wget unzip && \
        rm -rf /var/lib/apt/lists/* vm370sixpack-1_3.zip

EXPOSE 3270

CMD ["hercules", "-f", "sixpack.conf"]