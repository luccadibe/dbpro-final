1. About main.sh and it's relation with OSv folder

    - image is rebuilt for each command (power, boot) because for boot we don't neet to include the TPC-H data in the image.

    - 


2. Boot time: 2 approaches
    - `bash ./boot/bash-sqlite-timer/measure-boot-time 1 50`
    - `bash .boot/built-in-timer/measure-boot-time 1 50`
    - their comparison `boot/comparison.py`


3. Run queries

    - you will have to manually build the image and then run the script