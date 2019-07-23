#!/bin/bash -x

# Only need to define if on centos/redhat OS....
if [[ -f /etc/centos-release || -f /etc/redhat-release ]]
then
   
  function apt-add-repo() {
    echo "NOT TRANSLATED TO CENTOS"
    sleep 10
    return 0

    debreplist=/etc/apt/sources.list.d
    yumreplist=/etc/yum.conf
    sbtlist=$debreplist/sbt.list
    sbturl="$1"
    shift
    grep -c "deb $sbturl" $sbtlist
    if [ $? != 0 ]
    then
       echo "deb $sbturl /" | tee -a $sbtlist
    fi
  }

  function repo_remove() {
     #apt-get -qy remove "$@"
     return $?
  }

  function apt-get() {
     OPTIONS="-y"
     while [[ $1 = -* ]]
     do
	case "$1" in
	(-q|-qy|-y|-yq)
		;;

	(-f)	# Fix install with missing dependencies
		;;
	(--ignore-missing)
		OPTIONS="$OPTIONS --skip-broken"
		;;
	(*) 
		OPTIONS="$OPTIONS $1"
		;;
	esac
	shift
     done

     case "$1" in
	clean)
	  shift
	  yum clean all
	  return $?
	  ;;

	install)
	  shift
	  pkglist="$(map_pkglist "$@")"
	  if [[ -n "$pkglist" ]]
	  then
	     echo yum $OPTIONS install $pkglist
   	  yum $OPTIONS install $pkglist
	     return $?
	  else
	     return 0;
	  fi
	  ;;

	purge)
	  shift
	  pkglist="$(map_pkglist "$@")"
	  if [[ -n "$pkglist" ]]
          then
	     yum remove $OPTIONS $pkglist
	  fi
	  return $?
	  ;;
	remove)
	  shift
	  rpm -e  $OPTIONS "$@"
	  return $?
	  ;;

	update)
	  ;;

	upgrade)
	  if [[ "$OPTIONS" = *-s* ]]
	  then
	    cmd="check-update"
	  else
	    cmd="update"
	  fi
	  shift
	  yum $cmd "$@"
	  ;;
	  
     esac
     
  }

  function lookup_pkg() {
     case "$1" in

     # special mappings
     openjdk-?-jdk)
	v=$(echo $1 | cut -d- -f2)
	echo java-1.$v.0-openjdk java-1.$v.0-openjdk-devel
	;;

     # Generic 1to1 mapping
     *)
        # Associative arrap to map from apt to yum package names
	declare -A map
        # Map names
	map=(
	     # Items with mappings
	     [g++]=gcc-c++ 
	     [gdbserver]=gdb-gdbserver
	     [google-perftools]="gperftools"
	     [google-perftools]="gperftools"
	     [libboost-all-dev]="boost-devel" # "libboost*"
	     [libevent-dev]="libevent-devel"
	     [libgtest-dev]=gtest
	     [libssl-dev]="openssl-devel"
	     [openjdk-8-jdk]="java-1.8.0-openjdk java-1.8.0-openjdk-devel" 
	     [pkg-config]="pkgconfig"
	     [python-dev]="python-devel"
	     [python-numpy]="numpy"
	     [rpm]="rpm rpm-build"
	     [ssh]="openssh openssh-server"
	     [vnc4server]="vnc-server"
	     [binutils-dev]="binutils-devel"
	     [libbz2-dev]="bzip2-devel"

	     ## Items without mapping (or at least not required)
	     [libpam-modules]=none
	     [apt-transport-https]=none
	     [linux-tools-generic]=none
	     )
	# Lookup new pgk name
        newval=${map[$1]}
        # Not required?
        if [[ "$newval" == "none" ]]
	then
	   echo "No package for '$1'" >&2
	   echo ""   # ignore
	else
	   # If empty then assume name is the same
	   echo "${newval:=$1}"
 	fi
	;;
     esac
  }

  function map_pkglist() {
     pkgs=""
     while [ -n "$1" ]
     do
	pkgs="$pkgs $(lookup_pkg "$1")"
	shift
     done

     eval echo $pkgs
  }


  function dpkg() {
     OPTIONS=""
     CMD=""
     while [[ $1 = -* ]]
     do
	case "$1" in
	(-i)
		CMD=install
		OPTIONS="-y"
		;;

	(-s)
		CMD="list installed"
		;;

	(*) 
		OPTIONS="$OPTIONS $1"
		;;
	esac
	shift
     done
     yum ${OPTIONS} ${CMD} "$@"
  }

 function adduser() {
    cmd="useradd"
    while [ -n "$1" ]
    do
       option="$1"
       shift
       case "$option" in
          (--quiet)
	  	;;

          (--geco)
	  	shift	# remove arg
	  	;;

	  (--disabled-password)
             cmd="$cmd --password '*'"
	     ;;

          (--home)
             cmd="$cmd --home-dir $1"
             mkdir -p "$1"
	     shift
	     ;;

	  (--uid)
             cmd="$cmd --uid $1"
	     shift
	     ;;

	  (--gid|-g)
             cmd="$cmd --gid $1"
	     shift
	     ;;

	  (-*)
             cmd="$cmd $option"
	     ;;
		
	  (*)
	     if [ -z "$user" ]
	     then
	        user="$option"
	     else
	        group="$option"
	     fi
             cmd="$cmd $option"
	     ;;
       esac
    done
    if [[ -n "$user" && -n "$group" ]]
    then
       usermod --append --groups $group $user
    else
       $cmd
    fi
 }

 function addgroup() {
    cmd="groupadd"
    while [ -n "$1" ]
    do
       option="$1"
       shift
       case "$option" in
          (--quiet)
	  	;;

          (--geco)
	  	shift	# remove arg
	  	;;

	  (*)
             cmd="$cmd $option"
	     ;;
       esac
    done
    $cmd
 }

fi
