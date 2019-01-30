# Update R on EMR:

sudo yum update -y -q --skip-broken
sudo wget -q https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
sudo yum install -y -q apache-maven
#sudo alternatives --config java
sudo alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java
#sudo alternatives --config javac
sudo alternatives --set javac /usr/lib/jvm/java-1.8.0-openjdk.x86_64/bin/javac
wget -q http://cbs.centos.org/kojifiles/packages/protobuf/2.5.0/10.el7.centos/x86_64/protobuf-2.5.0-10.el7.centos.x86_64.rpm
wget -q http://cbs.centos.org/kojifiles/packages/protobuf/2.5.0/10.el7.centos/x86_64/protobuf-devel-2.5.0-10.el7.centos.x86_64.rpm
wget -q http://cbs.centos.org/kojifiles/packages/protobuf/2.5.0/10.el7.centos/x86_64/protobuf-compiler-2.5.0-10.el7.centos.x86_64.rpm
sudo yum -y -q install protobuf-2.5.0-10.el7.centos.x86_64.rpm protobuf-compiler-2.5.0-10.el7.centos.x86_64.rpm protobuf-devel-2.5.0-10.el7.centos.x86_64.rpm 
sudo yum install -y -q gcc-c++ make
curl -sL https://rpm.nodesource.com/setup_10.x | sudo -E bash -
sudo yum install -y -q nodejs
sudo npm install -g -s bower

sudo yum -y -q remove R R-base 

sudo yum -y -q install htop zlib-devel bzip2 bzip2-devel git git-core readline-devel sqlite sqlite-devel openssl-devel xz xz-devel xorg-x11-xauth libcurl-devel vlock readline xmlstarlet

sudo mkdir -m 777 /mnt/.pyenv
sudo git clone https://github.com/pyenv/pyenv.git /mnt/.pyenv
echo $'\nexport PYENV_ROOT="/mnt/.pyenv"' | sudo tee --append ~/.bash_profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
source ~/.bash_profile

# install latest miniconda3 version:
pyenv install `pyenv install --list | awk '/miniconda3-/' | awk 'END { print }'`
pyenv global `pyenv install --list | awk '/miniconda3-/' | awk 'END { print }'`

conda config --set always_yes true
conda config --add channels conda-forge

# this is for R/R-studio
conda install jupyter pip  r-base=3.5.1 r-irkernel rpy2 rstudio gfortran_linux-64
# this is for jupyter etc.:
#conda install jupyter pip r-irkernel rpy2 

conda update conda
conda clean --all

sudo yum -y remove gcc72-c++.x86_64 libgcc72.x86_64
sudo yum -y install gcc-gfortran

R -e 'options(Ncpus = parallel::detectCores()-2); lbs <- c("pacman", "magrittr", "dplyr", "data.table", "tidyr", "caret", "caretEnsemble", "earth", "xgboost", "foreach", "doParallel", "robustbase", "devtools", "iml", "DALEX"); req <- substitute(suppressMessages(require(x, character.only = TRUE))); sapply(lbs, function(x) eval(req) || {install.packages(x, quiet=TRUE, repos="http://cran.us.r-project.org"); eval(req)})'

cd /mnt
wget https://download2.rstudio.org/rstudio-server-rhel-1.1.463-x86_64.rpm
sudo yum -y -q install rstudio-server-rhel-1.1.463-x86_64.rpm

# If needed, use 'which R' to get below location:
export RSTUDIO_WHICH_R=/mnt/.pyenv/shims/R
echo "rsession-which-r=/mnt/.pyenv/shims/R" | sudo tee --append /etc/rstudio/rserver.conf
sudo rstudio-server start
sudo rstudio-server restart

sudo su
# Modify user/password as needed:
sudo useradd rstudio
sudo echo rstudio:rstudio | chpasswd

sudo rstudio-server restart

##############################
# To reach Rstudio, do the following in your local terminal:
# emr_public_dns="ec2-xx-xx-xx-xx.compute-1.amazonaws.com"
# ssh -i location-of-pam-file -N -L 8787:$public_dns:8787 hadoop@$emr_public_dns
# Follow this URL:
# http://localhost:8787
