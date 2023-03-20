FROM debian:stable-slim

ARG USERNAME=hercules
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN DEBIAN_FRONTEND=noninteractive \
        groupadd --gid $USER_GID $USERNAME && \
        useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
        apt update && \
        apt dist-upgrade -y && \
        apt install -y --no-install-recommends hercules wget unzip && \
        cd /home/$USERNAME && \
        wget http://www.smrcc.org.uk/members/g4ugm/vm-370/vm370sixpack-1_3.zip && \
        unzip vm370sixpack-1_3.zip && \
        chown -R $USERNAME:$USERNAME /home/$USERNAME && \
        # Remove unwanted files
        apt purge -y wget unzip && \
        rm -rf /var/lib/apt/lists/* vm370sixpack-1_3.zip

USER $USERNAME
WORKDIR /home/$USERNAME

EXPOSE 3270/TCP

CMD ["hercules", "-f", "sixpack.conf"]
