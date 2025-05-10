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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabled default Nodejs version"

dnf module enable nodejs:20 -y &>> $LOGFILE
VALIDATE $? "Enabled Nodejs version 20"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing NodeJs"

id roboshop
if [ $? != 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "creating roboshop user"
else
    echo -e "User already exists $Y SKIPPING $N"
fi


mkdir -p /app &>> $LOGFILE
VALIDATE $? "created app directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>> $LOGFILE
VALIDATE $? "Downloading cart code"

cd /app  &>> $LOGFILE
VALIDATE $? "moved to app directory"

unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "Unzipping cart code"

npm install &>> $LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "copying cart.service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading daemon"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "Enabling user"

systemctl start cart &>> $LOGFILE
VALIDATE $? "Starting user"
