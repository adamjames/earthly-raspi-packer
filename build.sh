#!/bin/sh

sudo earthly -i --allow-privileged \
--build-arg GITHUB_ACCESS_TOKEN=\
--build-arg CUSTOM_USER=adam \
--build-arg INITIAL_PASSWORD=changeme1! \
--build-arg DISABLE_ROOT=true \
--build-arg REMOVE_ALARM=true \
--build-arg HOSTNAME=arrpi \
+test