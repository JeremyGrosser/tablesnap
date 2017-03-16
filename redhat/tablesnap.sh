#!/bin/sh
#
# chkconfig:   - 85 15
# description: tablesnap
# processname: tablesnap
# pidfile:     /var/run/tablesnap.pid

# enable debug
#set -x

# default configuration file: 
. /etc/default/tablesnap

PID_FILE=/var/run/tablesnap.pid
PROGNAME=`basename $0`
TABLESNAP_BIN=/usr/bin/tablesnap

if [ "x$TABLESNAP_USER" = "x" ]; then
    TABLESNAP_USER=`whoami`
fi

if [ "x$TABLESNAP_LOGDIR" = "x" ]; then
    TABLESNAP_LOGDIR=/var/log/tablesnap/
fi

if [ ! -d $TABLESNAP_LOGDIR ]; then
    echo "Logging directory ${TABLESNAP_LOGDIR} does not exists!"
    exit 1
fi

start() {
    if [ -f $PID_FILE ]; then
        PID=`cat $PID_FILE`
        if  ps --pid $PID >/dev/null; then
            echo "$PROGNAME is already running: $PID"
            exit 0
        else
            echo "Removing stale pid file: $PID_FILE"
			rm -f $PID_FILE
        fi
    fi
    
    echo -n "Starting ${PROGNAME} with parameters ${TABLESNAP_PARAMETERS}"
    su $TABLESNAP_USER -c "${TABLESNAP_BIN} ${TABLESNAP_PARAMETERS} 1>>${TABLESNAP_LOGDIR}/tablesnap.log 2>&1 &"

    if [ $? == "0" ]; then
    	ps -U $TABLESNAP_USER -C python -o pid,cmd | grep $TABLESNAP_BIN | grep -v grep | awk {'print $1 '} > $PID_FILE
    	return 0;
    else
        return 1;
    fi   
}

stop() {
    if [ -f $PID_FILE ]; then
        echo -n "Stopping $PROGNAME..."
        PID=`cat $PID_FILE`
        su $TABLESNAP_USER -c "kill $PID"
        if kill $PID ; then
            sleep 5
            test -f $PID_FILE && rm -f $PID_FILE
            return 0;
        else
            echo "$PROGNAME could not be stopped..."
            return 1;
        fi
    else
        echo "$PROGNAME is not running."
        return 0;
    fi  
}

status() {
    if [ -f $PID_FILE ]; then
        PID=`cat $PID_FILE`
        if [ -z "$PID" ]; then
            echo "$PROGNAME isn't running, but PID file exists"
            return 1
        else
            echo "$PROGNAME is running...$PID"
            return 0
        fi
    else
        echo "$PROGNAME is not running."
        return 1;
    fi
    return 1
}

case "$1" in
    start)
        $1
        ;;
    stop)
        $1
        ;;
    restart)
        stop
        start
        ;;
    status)
        $1
        ;;
    *)
        echo "Usage: $SELF start|stop|restart|status"
        exit 1
    ;;
esac
