#!/bin/bash
# © Copyright IBM Corporation 2022.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
#
# Execute build script: bash build_kafka.sh    (provide -h for help)

set -e -o pipefail

PACKAGE_NAME="kafka"
PACKAGE_VERSION="3.6.0"
CURDIR="$(pwd)"
SOURCE_ROOT="$(pwd)"
FORCE="false"
LOG_FILE="$CURDIR/logs/${PACKAGE_NAME}-${PACKAGE_VERSION}-$(date +"%F-%T").log"
BUILD_ENV="$HOME/setenv.sh"
ROCKSDB_VERSION="7.9.2"
JAVA_PROVIDED="OpenJDK11"

trap cleanup 0 1 2 ERR

# Check if directory exists
if [ ! -d "$CURDIR/logs/" ]; then
    mkdir -p "$CURDIR/logs/"
fi

source "/etc/os-release"

function prepare() {
    if command -v "sudo" >/dev/null; then
        printf -- 'Sudo : Yes\n' >>"$LOG_FILE"
    else
        printf -- 'Sudo : No \n' >>"$LOG_FILE"
        printf -- 'Install sudo from repository using apt, yum or zypper based on your distro. \n'
        exit 1
    fi
    if [[ "$FORCE" == "true" ]]; then
        printf -- 'Force attribute provided hence continuing with install without confirmation message\n' |& tee -a "$LOG_FILE"
    else
        # Ask user for prerequisite installation
        printf -- "\nAs part of the installation , dependencies would be installed/upgraded.\n"
        while true; do
            read -r -p "Do you want to continue (y/n) ? :  " yn
            case $yn in
            [Yy]*)
                printf -- 'User responded with Yes. \n' >>"$LOG_FILE"
                break
                ;;
            [Nn]*) exit ;;
            *) echo "Please provide confirmation to proceed." ;;
            esac
        done
    fi
}

function cleanup() {
    # Remove artifacts
    cd "$CURDIR"
    if [[ $JAVA_PROVIDED == *11 ]]; then
                rm -rf  ibm-semeru-open-jdk_s390x_linux_11.0.16.1_1_openj9-0.33.1.tar.gz
                rm -rf  OpenJDK11U-jdk_s390x_linux_hotspot_11.0.16.1_1.tar.gz
    elif [[ $JAVA_PROVIDED == *17 ]]; then
                rm -rf   ibm-semeru-open-jdk_s390x_linux_17.0.5_8_openj9-0.35.0.tar.gz
                rm -rf  OpenJDK17U-jdk_s390x_linux_hotspot_17.0.6_10.tar.gz
    fi
    printf -- "Cleaned up the artifacts\n"
}

function configureAndInstall() {
    printf -- "Configuration and Installation started \n"
    if [[ "$JAVA_PROVIDED" == "Semeru11" ]]; then
                # Install AdoptOpenJDK 11 (With OpenJ9)
                printf -- "\nInstalling AdoptOpenJDK 11 (With OpenJ9) . . . \n"
                cd $SOURCE_ROOT
                wget https://github.com/ibmruntimes/semeru11-binaries/releases/download/jdk-11.0.16.1%2B1_openj9-0.33.1/ibm-semeru-open-jdk_s390x_linux_11.0.16.1_1_openj9-0.33.1.tar.gz
                tar -xzf ibm-semeru-open-jdk_s390x_linux_11.0.16.1_1_openj9-0.33.1.tar.gz
                export JAVA_HOME=$SOURCE_ROOT/jdk-11.0.16.1+1
                printf -- "Installation of AdoptOpenJDK 11 (With OpenJ9) is successful\n" >> "$LOG_FILE"
    elif [[ "$JAVA_PROVIDED" == "Temurin11" ]]; then
                # Install AdoptOpenJDK 11 (With Hotspot)
                printf -- "\nInstalling AdoptOpenJDK 11 (With Hotspot) . . . \n"
                cd $SOURCE_ROOT
                wget https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.16.1%2B1/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.16.1_1.tar.gz
                tar -xzf OpenJDK11U-jdk_s390x_linux_hotspot_11.0.16.1_1.tar.gz
                export JAVA_HOME=$SOURCE_ROOT/jdk-11.0.16.1+1
                printf -- "Installation of AdoptOpenJDK 11 (With Hotspot) is successful\n" >> "$LOG_FILE"
    elif [[ "$JAVA_PROVIDED" == "OpenJDK11" ]]; then
                if [[ "${ID}" == "ubuntu" ]]; then
                        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-11-jdk
                        export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x
                elif [[ "${ID}" == "rhel" ]]; then
                        sudo yum install -y java-11-openjdk-devel
                        export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
                elif [[ "${ID}" == "sles" ]]; then
                        sudo zypper install -y java-11-openjdk  java-11-openjdk-devel
                        export JAVA_HOME=/usr/lib64/jvm/java-11-openjdk
                fi
                printf -- "Installation of OpenJDK 11 is successful\n" >> "$LOG_FILE"
    elif [[ "$JAVA_PROVIDED" == "Semeru17" ]]; then
                # Install AdoptOpenJDK 17 (With OpenJ9)
                printf -- "\nInstalling AdoptOpenJDK 17 (With OpenJ9) . . . \n"
                cd $SOURCE_ROOT
                wget https://github.com/ibmruntimes/semeru17-binaries/releases/download/jdk-17.0.5%2B8_openj9-0.35.0/ibm-semeru-open-jdk_s390x_linux_17.0.5_8_openj9-0.35.0.tar.gz
                tar -xzf ibm-semeru-open-jdk_s390x_linux_17.0.5_8_openj9-0.35.0.tar.gz
                export JAVA_HOME=$SOURCE_ROOT/jdk-17.0.5+8
                printf -- "Installation of AdoptOpenJDK 17 (With OpenJ9) is successful\n" >> "$LOG_FILE"
    elif [[ "$JAVA_PROVIDED" == "Temurin17" ]]; then
                # Install AdoptOpenJDK 17 (With Hotspot)
                printf -- "\nInstalling AdoptOpenJDK 17 (With Hotspot) . . . \n"
                cd $SOURCE_ROOT
                        wget https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.6%2B10/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.6_10.tar.gz
                tar -xzf OpenJDK17U-jdk_s390x_linux_hotspot_17.0.6_10.tar.gz
                export JAVA_HOME=$SOURCE_ROOT/jdk-17.0.6+10
                printf -- "Installation of AdoptOpenJDK 17 (With Hotspot) is successful\n" >> "$LOG_FILE"
    elif [[ "$JAVA_PROVIDED" == "OpenJDK17" ]]; then
                if [[ "${ID}" == "ubuntu" ]]; then
                        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-17-jdk
                        export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-s390x
                elif [[ "${ID}" == "rhel" ]]; then
                        if [[ "${DISTRO}" == "rhel-7."* ]]; then
                         printf "$JAVA_PROVIDED is not available on RHEL 7.  Please use use valid variant from {Semeru8, OpenJDK8, Semeru11, Temurin11, OpenJDK11, Semeru17, Temurin17}.\n"
                         exit 1
                        fi
                        sudo yum install -y java-17-openjdk
                        if [[ "${DISTRO}" == rhel-8* ]] ; then
                                export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-17.0.7.0.7-3.el8.s390x
                        fi
                        if [[ "${DISTRO}" == rhel-9* ]] ; then
                                export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-17.0.7.0.7-3.el9.s390x
                        fi

                elif [[ "${ID}" == "sles" ]]; then
                        if [[ "${DISTRO}" == "sles-12.5" ]]; then
                            printf "$JAVA_PROVIDED is not available on SLES 12 SP5.  Please use use valid variant from {Semeru8, OpenJDK8, Semeru11, Temurin11, OpenJDK11, Semeru17, Temurin17}.\n"
                            exit 1
                        fi
                        sudo zypper install -y java-17-openjdk  java-17-openjdk-devel
                        export JAVA_HOME=/usr/lib64/jvm/java-17-openjdk
                fi
                printf -- "Installation of OpenJDK 17 is successful\n" >> "$LOG_FILE"
    fi
    export PATH=$JAVA_HOME/bin:$PATH
    printf -- "Java version is :\n"
    java -version
    
    # Apache KAFKA build starts
    # Download the source code and build the jar files
    printf -- "Download the source code and build the jar files\n"
    cd "$CURDIR"
    git clone https://github.com/apache/kafka.git
    cd kafka
    git checkout ${PACKAGE_VERSION}
    ./gradlew jar
    printf -- "Built Apache Kafka Jar successfully.\n"

    # Build and Create rocksdbjni-.jar for s390x
    cd "$CURDIR"
    if [[ "${DISTRO}" == "rhel-7.8" ]] || [[ "${DISTRO}" == "rhel-7.9" ]]; then
		yum install -y devtoolset-10-gcc
		source /opt/rh/devtoolset-10/enable
	fi
    git clone https://github.com/facebook/rocksdb.git
    cd rocksdb/
    git checkout v$ROCKSDB_VERSION
	cd java
	sudo mkdir target
	cd target
	sudo wget https://repo1.maven.org/maven2/org/rocksdb/rocksdbjni/$ROCKSDB_VERSION/rocksdbjni-$ROCKSDB_VERSION-linux64.jar
	sudo jar -xvf rocksdbjni-$ROCKSDB_VERSION-linux64.jar		
	cp $CURDIR/rocksdb/java/target/rocksdbjni-$ROCKSDB_VERSION-linux64.jar $CURDIR/rocksdbjni-$ROCKSDB_VERSION.jar
    cd "$CURDIR"
    printf -- "Built rocksdb and created rocksdbjni.jar successfully.\n"
    printf -- "Replace Rocksdbjni jar\n"
    cd $CURDIR
    find ./kafka/ ~/.gradle/ -name 'rocksdbjni-7.9.2.jar' -print0 | xargs -0 -n1 cp $CURDIR/rocksdbjni-7.9.2.jar
    

    # Test Apache Kafka
    cd $CURDIR/kafka
    if [[ "$JAVA_PROVIDED" == "Semeru11" || "$JAVA_PROVIDED" == "Semeru17" ]]; then
        ./gradlew test -PscalaOptimizerMode=method --continue
    else 
        ./gradlew test --continue
    fi

    cleanup
}

function logDetails() {
    printf -- '**************************** SYSTEM DETAILS *************************************************************\n' >>"$LOG_FILE"
    if [ -f "/etc/os-release" ]; then
        cat "/etc/os-release" >>"$LOG_FILE"
    fi

    cat /proc/version >>"$LOG_FILE"
    printf -- '*********************************************************************************************************\n' >>"$LOG_FILE"
    printf -- "Detected %s \n" "$PRETTY_NAME"
    printf -- "Request details : PACKAGE NAME= %s , VERSION= %s \n" "$PACKAGE_NAME" "$PACKAGE_VERSION" |& tee -a "$LOG_FILE"
}

# Print the usage message
function printHelp() {
    echo " bash build_kafka.sh [-d debug] [-y install-without-confirmation] "
    echo "  default: Eclipse Adoptium Temurin Runtime Java 11 will be installed"
}

while getopts "h?dyj:" opt; do
        case "$opt" in
        h | \?)
                printHelp
                exit 0
                ;;
        d)
                set -x
                ;;
        y)
                FORCE="true"
                ;;
        j)
                JAVA_PROVIDED="$OPTARG"
                ;;
        esac
done

function gettingStarted() {
    printf -- '\n********************************************************************************************************\n'
    printf -- "\n* Getting Started * \n"
    printf -- "\n Note: Environment Variables(JAVA_HOME) needed have been added to $HOME/setenv.sh\n"
    printf -- "\n Note: To set the Environment Variables needed for Apache Kafka, please run: source $HOME/setenv.sh \n"
    printf -- "\n To run the unit tests of Apache Kafka, please run:"
    printf -- "\n        cd $CURDIR/kafka"
    printf -- "\n        ./gradlew test --continue    \n"
    printf -- "\n If any test fails due to timeout, try running it individually\n"
    printf -- "\n If the testing process hangs and stops making progress, it might be helpful to increase the limit of"
    printf -- "\n opening files using command ulimit -n <new_value> and restart the tests\n"
    printf -- "\n You could also try to use forkEvery = 1 gradle option for testing to reduce the number of test case failure\n"
    printf -- "\n To start Apache Kafka server refer: https://kafka.apache.org/quickstart#quickstart_startserver  \n\n"
    printf -- '**********************************************************************************************************\n'
}

logDetails
prepare # Check Prerequisites
DISTRO="$ID-$VERSION_ID"

case "$DISTRO" in
"ubuntu-22.04" | "ubuntu-20.04" | "ubuntu-23.10" | "ubuntu-23.04")
    printf -- "Installing %s %s for %s \n" "$PACKAGE_NAME" "$PACKAGE_VERSION" "$DISTRO" |& tee -a "$LOG_FILE"
    printf -- "Installing dependencies... it may take some time.\n"
    sudo apt-get update
    sudo apt-get -y install wget tar git curl unzip
    configureAndInstall |& tee -a "$LOG_FILE"
    ;;

"rhel-7.8" | "rhel-7.9" | "rhel-8.6" | "rhel-8.8" | "rhel-9.0" | "rhel-9.2")
    printf -- "Installing %s %s for %s \n" "$PACKAGE_NAME" "$PACKAGE_VERSION" "$DISTRO" |& tee -a "$LOG_FILE"
    printf -- "Installing dependencies... it may take some time.\n"
    sudo yum install -y wget tar git curl unzip ca-certificates curl wget tar glibc make
    configureAndInstall |& tee -a "$LOG_FILE"
    ;;

"sles-12.5" | "sles-15.4" | "sles-15.5")
    printf -- "Installing %s %s for %s \n" "$PACKAGE_NAME" "$PACKAGE_VERSION" "$DISTRO" |& tee -a "$LOG_FILE"
    printf -- "Installing dependencies... it may take some time.\n"
    sudo zypper install -y wget tar git curl unzip gzip curl wget tar make libnghttp2-devel
    configureAndInstall |& tee -a "$LOG_FILE"
    ;;
*)
    printf -- "%s not supported \n" "$DISTRO" |& tee -a "$LOG_FILE"
    exit 1
    ;;
esac

gettingStarted |& tee -a "$LOG_FILE"
