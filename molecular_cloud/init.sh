#!/bin/bash

rm -f data/do-key*
ssh-keygen -t rsa -f data/do-key -N ""
