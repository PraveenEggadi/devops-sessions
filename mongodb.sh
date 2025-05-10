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
        echo -e "ERROR: $2 has $R FAILED $N"
        exit 1
    else
        echo -e "$2 $G SUCCESS $N!"
    fi
}

if [ $ID != 0 ]
then 
    echo -e "$R ERROR: Run the script with ROOT access $N"
    exit 1
else
    echo -e "$G Root User $N"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copied MONGODB Repo"

dnf install mongodb-org -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "Enabled MongoDB"
systemctl start mongod  &>> $LOGFILE
VALIDATE $? "Starting MOngoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Remote access to MongoDB"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restarting MOngoDB"