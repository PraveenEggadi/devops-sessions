#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "ERROR: $2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N!"
    fi
}

if [ $ID != 0 ]
then 
    echo -e "$R ERROR: Run the script with ROOT access $N"
    exit 1
else
    echo -e "$G Root User $N"
fi
dnf module disable redis -y &>> $LOGFILE
VALIDATE $? "Disabling redis"

dnf module enable redis:7 -y &>> $LOGFILE
VALIDATE $? "Enabling redis:7"

dnf install redis -y &>> $LOGFILE
VALIDATE $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOGFILE
sed -i 's/^protected-mode yes/protected-mode no/g' /etc/redis/redis.conf &>> $LOGFILE
# sed -i 's/

systemctl enable redis &>> $LOGFILE
VALIDATE $? 'Enabling Redis'

systemctl start redis &>> $LOGFILE
VALIDATE $? "Starting redis"