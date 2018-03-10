#!/bin/bash
#GameServer 开关服用
#start正常 start_mon 开启监控 start_debug 开启debug 
##
##
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

_ScriptFile=$(basename $0) 
_ScriptDir=$(dirname $_ScriptFile)      
maxTime=5        
pidDIR=$_ScriptDir/PIDDIR
_SPort=`cat config.xml | sed -n '/ServerPort/p' | awk -F ">|</" '{print $2}'`

_JMXPORT=`expr $_SPort - 1000`
_DEBUGPORT=`expr $_SPort - 2000`

pidFileList="Server.pid"


[ -d $pidDIR ] || mkdir $pidDIR
ulimit -HSn 65535

_Java_mode=$2

pidFile1="$pidDIR/Server.pid"    
#export JAVA_HOME="/usr/local/jrockit"


JAVA_OPTS1="-Xms1024m -Xmx9600m -Xmn512m -Xss1024k"
JAVA_OPTS2="-verbose:gc -XX:+PrintGCDetails -XX:+HeapDumpOnOutOfMemoryError"
#JAVA_OPTS3="-Xmanagement -Dcom.sun.management.jmxremote.port=7091 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
JAVA_OPTS3="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=${_JMXPORT}"

if [ "$_Java_mode" != "jc" ] ;then
	_JAVA="/usr/bin/jrockit -jar -server" 
else 
	_JAVA="/usr/bin/java -jar -server"
fi	

JAVA_OPTS4="-Xdebug -Xrunjdwp:transport=dt_socket,address=${_DEBUGPORT},server=y,suspend=n"


	function makeFileWritable {
		filename="$1"
		touch $filename || return 1
		return 0; 
	}
	

	function checkProcessIsRunning {
		pid="$1"
		if [ -z "$pid" -o "$pid" == " " ]; then return 1; fi
		if [ ! -e /proc/$pid ]; then return 1; fi
		return 0; 
	}
	
	function stopservice() {
		
		for i in $pidFileList
		do
			_pf="$pidDIR/$i"
			servicePid="$(<${_pf})"
			kill $servicePid
		done
	}
	
	function checkservice() {
	
		for i in $pidFileList;do
			_pf="$pidDIR/$i"
			servicePid="$(<${_pf})"
			checkProcessIsRunning $servicePid ||  return 1
		done	
	}
	
	function delcache() {
	
		if [ -d fdb ] || [ -d online ] ;then
			rm -rf fdb/* online/*
			[ $? -eq 0 ] && { echo 1 && return 0; } || return 1
		else
			return 2
		fi	
	}
	
	
	function checkstatus() {
	
		checkservice && echo 1 || { echo 0 && return 1; }
	
	}
	
	function startserver() {
		###传值进来，启动不同类型，以后再加
		_stype=$1
		
		checkservice && { echo 0 && exit 2; }
		
		case $_stype in
		
		debug)
			
			nohup $_JAVA $JAVA_OPTS3 $JAVA_OPTS4 server.jar > serverlog 2>&1 & echo $! >$pidFile1 
			sleep 1
			checkservice && echo 1 || { echo 0 && return 1; }
		
		;;
		
		*)
		
			nohup $_JAVA server.jar > serverlog 2>&1 & echo $! >$pidFile1 
			sleep 1
			checkservice && echo 1 || { echo 0 && return 1; }
		
		;;
		esac
		

		
	}
	
	function useage() {
	
		echo "sh $0 stop | start | status | delcache"
	}


	
	for i in $pidFileList;do
        _pf="$pidDIR/$i"
		if [ ! -f $_pf ]; then 
			makeFileWritable $_pf || exit 1 
		fi
	done

	case "$1" in 
	
	
	start)
		
		startserver debug

	;;
	
	start_debug_mon)

		startserver debug

	;;
	
	stop)
	
		checkservice || { echo 0 && exit 1; }
		stopservice
		while checkservice 
		do
		sleep 1
		done
		[ $? -eq 0 ] && echo 1 
		
	
	;;
	status)
	
		checkstatus
		
	;;
	
	delcache)
			
		delcache
	;;
	
	*)
		useage
	;;
	
	
	esac

	
	
	
	
	
	