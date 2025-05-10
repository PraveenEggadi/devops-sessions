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

dnf module disable nginx -y &>> $LOGFILE
VALIDATE $? "disabling nginx"

dnf module enable nginx:1.24 -y &>> $LOGFILE
VALIDATE $? "Enabling nginx"

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "Enabling nginx"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "Removing content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Downloading web code"

cd /usr/share/nginx/html 
VALIDATE $? "moved to directory"

unzip -o /tmp/frontend.zip
VALIDATE $? "Unzipping web"

cp /home/ec2-user/roboshop-shell/roboshop.conf /etc/nginx/nginx.conf

systemctl restart nginx &>> $LOGFILE
VALIDATE $? "restart web"
