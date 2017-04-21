#!/bin/bash
( cd ~/curofy && git fetch --tags )
( cd ~/curofy && git tag > ~/Brandon/tags.txt )

