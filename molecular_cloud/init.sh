#!/bin/bash

rm -fr data/*
mkdir -p data
ssh-keygen -t rsa -f data/do-key -N ""
