#!/bin/sh

sudo earthly -i --allow-privileged \
--build-arg GITHUB_ACCESS_TOKEN=github_pat_YOUR_TOKEN_HERE \
--build-arg CUSTOM_USER=adam \
--build-arg DISABLE_ROOT=true \
--build-arg REMOVE_ALARM=true \
--build-arg HOSTNAME=arrpi \
+export