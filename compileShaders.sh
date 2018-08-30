#!/bin/bash

cd assets/base/vktest

glslangValidator base.vert -V
glslangValidator base.frag -V
