#!/bin/sh

# generate host keys if not present
ssh-keygen -A

# check whether a random root-password is provided
if [ ! -z ${ROOT_PASSWORD} ] && [ "${ROOT_PASSWORD}" != "root" ]; then
    echo "root:${ROOT_PASSWORD}" | chpasswd
else
    ROOT_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)
    echo "root:${ROOT_PASSWORD}" | chpasswd
fi

mkdir -p /root/.ssh
touch /root/.ssh/authorized_keys
echo ${ROOT_AUTHORIZED_KEY} > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# check if user is provided
if [ ! -z ${USERNAME} ] && [ ! -z ${USER_PASSWORD} ] && [ ! -z ${USER_ID} ] && [ ! -z ${USER_GROUP_ID} ] && [ -z ${USER_AUTHORIZED_KEY} ]; then
    adduser -u ${USER_ID} -G ${USER_GROUP_ID} -s /bin/bash ${USERNAME}
    echo "${USERNAME}:${USER_PASSWORD}" | chpasswd
    mkdir -p /home/${USERNAME}/.ssh
    touch /home/${USERNAME}/.ssh/authorized_keys
    echo ${USER_AUTHORIZED_KEY} > /home/${USERNAME}/.ssh/authorized_keys
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh
    chmod 600 /home/${USERNAME}/.ssh
fi

# do not detach (-D), log to stderr (-e), passthrough other arguments
exec /usr/sbin/sshd -D -e "$@"
