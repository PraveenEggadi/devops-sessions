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

dnf install python3 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "installing python"

id roboshop
if [ $? != 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "creating roboshop user"
else
    echo -e "User already exists $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "created directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>> $LOGFILE
VALIDATE $? "downloaded payment"

cd /app 

unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "Unzipping payment"

pip3 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "installing dependencies"

cp /home/ec2-user/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "copied payment service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reloaded"

systemctl enable payment &>> $LOGFILE
VALIDATE $? "Enabling payment"

systemctl start payment &>> $LOGFILE
VALIDATE $? "Starting payment"
