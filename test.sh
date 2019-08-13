#!/bin/bash -xe

SCENARIO=${1:-default}

if docker inspect travis > /dev/null 2>&1 ; then
  docker stop travis
  sleep 1
fi
docker run \
  --rm \
  -p 2222:22 \
  --name travis \
  --privileged -d \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  travisci/ci-ubuntu-1804:packer-1565538440-761b0051 \
  /lib/systemd/systemd
cat ~/.ssh/id_rsa.pub | \
  docker exec \
  -i \
  -u travis \
  travis dd of=/home/travis/.ssh/authorized_keys
docker exec travis chmod og-rwx /home/travis/.ssh/authorized_keys
docker exec travis dpkg-reconfigure openssh-server
docker exec travis systemctl restart ssh
molecule test -s $SCENARIO
docker stop travis
