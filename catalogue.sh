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

useradd roboshop &>> $LOGFILE
VALIDATE $? "User roboshop created"

mkdir /app &>> $LOGFILE
VALIDATE $? "created app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOGFILE
VALIDATE $? "Downloading catalogue code"

cd /app  &>> $LOGFILE
VALIDATE $? "moved to app directory"

unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "Unzipping catalogue code"

npm install &>> $LOGFILE
VALIDATE $? "Installing dependencies"

# use absolute path sice catalogue.service exists in that location
cp /home/ec2-user/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue.service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading daemon"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "Enabling catalogue"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "Starting catalogue"

cp /home/ec2-user/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongo repo"

dnf install mongodb-mongosh -y &>> $LOGFILE
VALIDATE $? "Installing mongodb client"

mongosh --host mongodb.join-aws-devops.shop </app/db/master-data.js
VALIDATE $? "Loading catalogue data into mongodb"