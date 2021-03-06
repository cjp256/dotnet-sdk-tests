#!/bin/bash -xe
#
# Install built snaps, connecting required plugs.
#

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $SCRIPT_DIR

pushd dotnet-runtime-31-2004
sudo snap install *.snap --dangerous
popd

pushd dotnet-sdk-31-2004
sudo snap install *.snap --dangerous --classic
popd

name="dotnet-hello"
pushd $name
sudo snap install *.snap --dangerous
sudo snap connect $name:process-control
popd

name="dotnet-hello-using-dotnet-runtime-snap"
pushd $name
sudo snap install *.snap --dangerous
sudo snap connect $name:dotnet-runtime-31-2004 dotnet-runtime-31-2004
sudo snap connect $name:process-control
popd

popd #$SCRIPT_DIR
