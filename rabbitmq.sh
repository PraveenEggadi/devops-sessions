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

cp /home/ec2-user/roboshop-shell/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo

dnf install rabbitmq-server -y &>> $LOGFILE
VALIDATE $? "Installing rabbitmq"

systemctl enable rabbitmq-server &>> $LOGFILE
VALIDATE $? "enabling rabbitmq"

systemctl start rabbitmq-server &>> $LOGFILE
VALIDATE $? "starting rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE