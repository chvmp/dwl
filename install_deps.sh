#!/bin/bash

# List of usefull colors
COLOR_RESET="\033[0m"
COLOR_INFO="\033[0;32m"
COLOR_ITEM="\033[1;34m"
COLOR_QUES="\033[1;32m"
COLOR_WARN="\033[0;33m"
COLOR_BOLD="\033[1m"
COLOR_UNDE="\033[4m"


function install_eigen
{
	# get Eigen 3.2.4
	wget http://www.bitbucket.org/eigen/eigen/get/3.2.4.tar.bz2
	tar jxf 3.2.4.tar.bz2
	cd eigen-eigen-10219c95fe65
	mkdir -p build
	cd build
	cmake ../
	make install
	cd ../../
	rm -rf 3.2.4.tar.bz2
}


function install_yamlcpp
{
	# Getting the YAML-CPP 0.3.0
	wget https://yaml-cpp.googlecode.com/files/yaml-cpp-0.3.0.tar.gz
	tar zxf yaml-cpp-0.3.0.tar.gz
	cd yaml-cpp
	mkdir -p build
	cd build
	cmake ../
	make install
	cd ../../
	rm -rf yaml-cpp-0.3.0.tar.gz
}


function install_octomap
{
	# get Octomap 1.6.8
	wget https://github.com/OctoMap/octomap/archive/v1.6.8.tar.gz
	tar zxf v1.6.8.tar.gz
	cd octomap-1.6.8
	mkdir -p build
	cd build
	cmake ../
	make install
	cd ../../
	rm -rf v1.6.8.tar.gz
}


function install_ipopt
{
	# Getting Ipopt 3.9.3
	wget http://www.coin-or.org/download/source/Ipopt/Ipopt-3.9.3.tgz
	tar xzvf Ipopt-3.9.3.tgz
	# Documentation for Ipopt Third Party modules:
	# http://www.coin-or.org/Ipopt/documentation/node13.html
	cd Ipopt-3.9.3/ThirdParty
	# Getting Blas dependency
	cd Blas
	sed -i 's/ftp:/http:/g' get.Blas
	./get.Blas
	cd ..
	# Getting Lapack dependency
	cd Lapack
	sed -i 's/ftp:/http:/g' get.Lapack
	./get.Lapack
	cd ..
	# Getting Metis dependency
	cd Metis
	sed -i 's/metis\/metis/metis\/OLD\/metis/g' get.Metis
	sed -i 's/metis-4\.0/metis-4\.0\.1/g' get.Metis
	sed -i 's/mv metis/#mv metis/g' get.Metis
	./get.Metis
	# Patching is necessary. See http://www.math-linux.com/mathematics/Linear-Systems/How-to-patch-metis-4-0-error
	wget http://www.math-linux.com/IMG/patch/metis-4.0.patch
	patch -p0 < metis-4.0.patch
	cd ..
	# Getting Mumps dependency
	cd Mumps
	./get.Mumps
	cd ..
	# Getting ASL dependency
	cd ASL
	wget --recursive --include-directories=ampl/solvers http://www.netlib.org/ampl/solvers || true
	rm -rf solvers
	mv www.netlib.org/ampl/solvers .
	rm -rf www.netlib.org/
	sed -i 's/^rm/# rm/g' get.ASL
	sed -i 's/^tar /# tar/g' get.ASL
	sed -i 's/^$wgetcmd/# $wgetcmd/g' get.ASL
	cd ..
	# bugfix of http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=625018#10
	cd ..
	sed -n 'H;${x;s/#include "IpReferenced.hpp"/#include <cstddef>\
	\
	&/;p;}' Ipopt/src/Common/IpSmartPtr.hpp > IpSmartPtr.hpp
	mv IpSmartPtr.hpp Ipopt/src/Common/IpSmartPtr.hpp
	sed -n 'H;${x;s/#include <list>/&\
	#include <cstddef>/;p;}' Ipopt/src/Algorithm/LinearSolvers/IpTripletToCSRConverter.cpp > IpTripletToCSRConverter.cpp
	mv IpTripletToCSRConverter.cpp Ipopt/src/Algorithm/LinearSolvers/IpTripletToCSRConverter.cpp
	# create build directory
	mkdir -p build
	cd build
	# start building
	../configure --enable-static --prefix ~/Ipopt-3.9.3
	make install
	cd ../../
	rm -rf Ipopt-3.9.3.tgz
}






# Check user and run as root if necessary
if [ "$USER" != "root" ]; then
	SUDO=$(sudo -v 2>&1)

	if [ -z "$SUDO" ]; then  # We can run the command with sudo
    	echo -e "${COLOR_INFO}Running the script with sudo${COLOR_RESET}"
    	sudo $0 $*
	else                        # We need to login as root
    	echo -e "${COLOR_INFO}Login as root${COLOR_RESET}"
    	su -c "$0 $*"
	fi

	exit
fi

echo -e "${COLOR_BOLD}install_deps.sh - DWL Installation Script for Ubuntu Precise Pangolin 12.04${COLOR_RESET}"
echo ""
echo "Copyright (C) 2015 Carlos Mastalli"
echo ""
echo "This program comes with ABSOLUTELY NO WARRANTY."
echo "This is free software, and you are welcome to redistribute it"
echo "under certain conditions; see the filecontent for more information."

# This file is part of DWL Installer.
#
# Psopt Installer is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Psopt Installer is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with DWL Installer.  If not, see
# <http://www.gnu.org/licenses/>.

echo ""
read -s -p "Press enter to start the installation." 
echo ""


mkdir -p thirdparty
cd thirdparty

##---------------------------------------------------------------##
##---------------------- Installing Eigen -----------------------##
##---------------------------------------------------------------##
echo ""
echo -e "${COLOR_BOLD}Installing Eigen ...${COLOR_RESET}"
echo ""
if [ -d "/usr/local/include/eigen3" ]; then
	echo -e "${COLOR_QUES}Do you want to re-install Eigen 3.2.4? (Y/N)${COLOR_RESET}"
	read ANSWER_EIGEN
	if [ "$ANSWER_EIGEN" == "Y" ] || [ "$ANSWER_EIGEN" == "y" ]; then
		install_eigen
    fi
else
	install_eigen
fi

##---------------------------------------------------------------##
##-------------------- Installing YAML-CPP ----------------------##
##---------------------------------------------------------------##
echo ""
echo -e "${COLOR_BOLD}Installing YAML-CPP ...${COLOR_RESET}"
echo ""
if [ -d "/usr/local/include/yaml-cpp" ]; then
	echo -e "${COLOR_QUES}Do you want to re-install YAML-CPP 0.3.0? (Y/N)${COLOR_RESET}"
	read ANSWER_EIGEN
	if [ "$ANSWER_EIGEN" == "Y" ] || [ "$ANSWER_EIGEN" == "y" ]; then
		install_yamlcpp
    fi
else
	install_yamlcpp
fi


##---------------------------------------------------------------##
##---------------------- Installing Octomap -----------------------##
##---------------------------------------------------------------##
echo ""
echo -e "${COLOR_BOLD}Installing Octomap ...${COLOR_RESET}"
echo ""
if [ -d "/usr/local/include/octomap" ]; then
	echo -e "${COLOR_QUES}Do you want to re-install Octomap 1.6.8? (Y/N)${COLOR_RESET}"
	read ANSWER_OCTOMAP
	if [ "$ANSWER_OCTOMAP" == "Y" ] || [ "$ANSWER_OCTOMAP" == "y" ]; then
		install_octomap
    fi
else
	install_octomap
fi

##---------------------------------------------------------------##
##---------------------- Installing Ipopt -----------------------##
##---------------------------------------------------------------##
echo -e "${COLOR_BOLD}Installing Ipopt ...${COLOR_RESET}"
echo ""
if [ -d "Ipopt-3.9.3" ]; then
	# Control will enter here if $DIRECTORY exists.
	echo -e "${COLOR_QUES}Do you want to re-install Ipopt 3.9.3? (Y/N)${COLOR_RESET}"
	read ANSWER_IPOPT
	if [ "$ANSWER_IPOPT" == "Y" ] || [ "$ANSWER_IPOPT" == "y" ]; then
		install_ipopt
    fi
else
	install_ipopt
fi
