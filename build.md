## Building MySQL 5.x

Below versions of MySQL are available in respective distributions at the time creation of these build instructions:

*	Ubuntu 18.04 has `5.7.39`

The instructions provided below specify the steps to build [MySQL](https://www.mysql.com/) version 5.7.39 on Linux on IBM Z for the following distributions:
*	RHEL (7.8, 7.9)

_**General Notes:**_
*   _When following the steps below please use a standard permission user unless otherwise specified._
*   _A directory `/<source_root>/` will be referred to in these instructions, this is a temporary writable directory anywhere you'd like to place it._

## Build MySQL

### Step 1: Build using script

If you want to build MySQL using manual steps, go to Step 2.

Use the following commands to build MySQL using the build [script](https://github.com/linux-on-ibm-z/scripts/tree/master/MySQL). Please make sure you have wget installed.

```bash
wget -q https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/MySQL/5.7.39/build_mysql.sh
# Build MySQL
bash build_mysql.sh   [Provide -t option for executing build with tests]
```

If the build completes successfully, go to STEP 4. In case of error, check `logs` for more details or go to STEP 2 to follow manual build steps.


### Step 2: Install the dependencies
```
export SOURCE_ROOT=/<source_root>/
```

*   RHEL (7.8, 7.9)
    ```shell
    sudo yum install -y bison cmake gcc gcc-c++ git hostname make ncurses-devel openssl openssl-devel
    ```

### Step 3: Build MySQL

#### 3.1) Download the MySQL source code from Github

```shell
cd $SOURCE_ROOT
git clone https://github.com/mysql/mysql-server
cd mysql-server
git checkout mysql-5.7.39
mkdir build
cd build
```

#### 3.2) Configure MySQL

```shell
 cmake .. -DDOWNLOAD_BOOST=1 -DWITH_BOOST=. -DWITH_SSL=system
 ```
 **Note:** For more MySQL source configuration options, please visit their official [guide](https://dev.mysql.com/doc/refman/5.7/en/source-configuration-options.html).

#### 3.3) Build and Install MySQL

```shell
make
sudo make install
```

#### 3.4) Run unit tests (Optional)

The testing should take only a few seconds.

```shell
make test
```

### Step 4: Post installation setup (Optional)

Refer to this [guide](https://dev.mysql.com/doc/refman/5.7/en/postinstallation.html) for the Postinstallation Setup and Testing overview.

Clean up (Optional)

```shell
cd $SOURCE_ROOT
rm -rf mysql-server
```

### References:
- [https://dev.mysql.com/doc/refman/5.7/en/](https://dev.mysql.com/doc/refman/5.7/en/) - MySQL 5.7 Reference Manual  
- [https://dev.mysql.com/doc/refman/5.7/en/source-installation.html](https://dev.mysql.com/doc/refman/5.7/en/source-installation.html) - Installing MySQL from Source
