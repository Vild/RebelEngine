#!/bin/bash

cd assets/base/vktest

rm *.spv

glslangValidator base.vert -V110 -e main -S vert -o vert.spv
glslangValidator base.frag -V110 -e main -S frag -o frag.spv
