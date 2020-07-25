#!/bin/bash

echo
echo -e "\e[32m开始\e[0m"
echo





if true; then
    echo
    echo -e "--- \e[35m阿里云\e[0m --------------------------"
    echo

    git  push  aliyun

    echo
fi





if true; then
    echo
    echo -e "--- \e[31m码云 wlc\e[0m ----------------------------"
    echo

    git  push  gitee-wlc

    echo
fi





if true; then
    echo
    echo -e "--- \e[33mGitHub\e[0m -------------------------"
    echo

    git  push  github

    echo
fi





echo
echo -e "\e[42;30m Git 推送至所有源：结束 \e[0;0m"
echo
