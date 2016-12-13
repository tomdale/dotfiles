#!/bin/sh

if [ "$SHELL" != "/bin/zsh" ]
then
  chsh -s $(which zsh)
fi