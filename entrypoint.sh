#!/bin/sh

# generate host keys if not present
ssh-keygen -A

# check wether a random root-password is provided
if [ ! -z ${ROOT_PASSWORD} ] && [ -z ${ROOT_AUTHORIZED_KEY} ] && [ "${ROOT_PASSWORD}" != "root" ]; then
    echo "root:${ROOT_PASSWORD}" | chpasswd
    mkdir -p /root/.ssh
    touch /root/.ssh/authorized_keys
    echo ${ROOT_AUTHORIZED_KEY} > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi

# check if user is provided
if [ ! -z ${USER} ] && [ ! -z ${USER_PASSWORD} ] && [ ! -z ${USER_ID} ] && [ ! -z ${USER_GROUP_ID} ] && [ -z ${USER_AUTHORIZED_KEY} ]; then
    useradd -m -u ${USER_ID} -g ${USER_GROUP_ID} -s /bin/bash ${USER}
    echo "${USER}:${USER_PASSWORD}" | chpasswd
    mkdir -p /home/${USER}/.ssh
    touch /home/${USER}/.ssh/authorized_keys
    echo ${USER_AUTHORIZED_KEY} > /home/${USER}/.ssh/authorized_keys
    chown -R ${USER}:${USER} /home/${USER}/.ssh
    chmod 600 /home/${USER}/.ssh
fi

# do not detach (-D), log to stderr (-e), passthrough other arguments
exec /usr/sbin/sshd -D -e "$@"
