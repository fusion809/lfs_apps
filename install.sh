#!/bin/bash
mkdir -p ~/.local/share/applications
ln -sf $PWD/{julia,plotbts}.desktop ~/.local/share/applications
mkdir -p ~/.local/bin/
ln -sf $PWD/plotbts ~/.local/bin/
