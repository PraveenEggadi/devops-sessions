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
    VALIDATE $? "creating roboshop user $Y SKIPPING $N"
else
    echo -e "User already exists"
fi


mkdir -p /app &>> $LOGFILE
VALIDATE $? "created app directory"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>> $LOGFILE
VALIDATE $? "Downloading user code"

cd /app  &>> $LOGFILE
VALIDATE $? "moved to app directory"

unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? "Unzipping user code"

npm install &>> $LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "copying user.service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading daemon"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "Enabling user"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "Starting user"
