#!/bin/bash

echo '/tmp/core.%h.%e.%t' > /proc/sys/kernel/core_pattern
ulimit -c unlimited

/usr/bin/start-postgres