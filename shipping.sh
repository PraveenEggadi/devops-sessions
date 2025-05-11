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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "installing maven"

useradd roboshop &>> $LOGFILE
VALIDATE $? "User added"

mkdir -p /app &>> $LOGFILE
VALIDATE $? "created directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> $LOGFILE
VALIDATE $? "downloaded shipping appln"

cd /app &>> $LOGFILE
VALIDATE $? "inside app"

unzip /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "Unzipping shiiping code"

mvn clean package &>> $LOGFILE
VALIDATE $? "instaliing maven dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "moved shipping "

cp /home/ec2-user/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "copying shipping service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reload Daemon"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "Enabling shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "Starting shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "installing mysql client"

mysql -h mysql.join-aws-devops.shop -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LOGFILE

mysql -h mysql.join-aws-devops.shop -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LOGFILE

mysql -h mysql.join-aws-devops.shop -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOGFILE

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "Restarting shipping"