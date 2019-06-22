#!/usr/bin/env bash
for bcfile in /etc/bash_completion.d/* ; do
  . "$bcfile"
done