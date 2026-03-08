#!/bin/bash
mkdir -p ~/.local/share/applications
ln -sf $PWD/{julia,plotbts,plotbtsa,plotbtso}.desktop ~/.local/share/applications
mkdir -p ~/.local/bin/
ln -sf $PWD/{plotbts,plotbtsa,plotbtso} ~/.local/bin/
