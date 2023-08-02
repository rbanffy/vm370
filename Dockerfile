# syntax=docker/dockerfile:1

FROM alpine:latest AS builder

RUN apk update && \
        apk add alpine-sdk automake cmake autoconf libtool linux-headers zlib-dev bash && \
        wget https://github.com/SDL-Hercules-390/hyperion/archive/refs/heads/master.zip && \
        unzip master.zip && \
        cd /hyperion-master && \
        sh autogen.sh && \
        ./configure && \
        make && \
        make install

FROM alpine:latest

ARG USERNAME=hercules
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN apk --no-cache update && \
        apk --no-cache add ca-certificates && \
        addgroup -g $USER_GID $USERNAME && \
        adduser -u $USER_UID -G $USERNAME -D $USERNAME && \
        cd /home/$USERNAME && \
        wget http://www.smrcc.org.uk/members/g4ugm/vm-370/vm370sixpack-1_3.zip && \
        unzip vm370sixpack-1_3.zip && \
        # Enable CMS/DOS disks
        sed -i 's/#06a0/06a0/' sixpack.conf && \
        sed -i 's/#07a0/07a0/' sixpack.conf && \
        # Enable web UI with the MAINT credentials
        sed -i 's/#HTTPPORT       8081/HTTP PORT    8081    AUTH MAINT CPCMS\nHTTP START/' sixpack.conf && \
        # Log off the OPERATOR user from the Hercules console
        echo '/LOGOFF' >> hercules.rc && \
        chown -R $USERNAME:$USERNAME /home/$USERNAME && \
        # mkdir -p /usr/local/lib/hercules && \
        # Remove unwanted files
        rm -rf vm370sixpack-1_3.zip

# Copy Hercules proper
COPY --from=0 /usr/local/lib/hercules/* /usr/local/lib/hercules/
COPY --from=0 /usr/local/lib/libherc* /usr/local/lib/
COPY --from=0 /usr/local/bin/* /usr/local/bin
# Copy the HTML UI files
COPY --from=0 /hyperion-master/html /usr/local/share/hercules/

USER $USERNAME
WORKDIR /home/$USERNAME

EXPOSE 3270/TCP
EXPOSE 8081/TCP

CMD ["hercules", "-f", "sixpack.conf"]
