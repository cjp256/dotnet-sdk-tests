#!/bin/bash -xe

pushd dotnet-runtime-31-2004
snapcraft snap
sudo snap install *.snap --dangerous
popd

pushd dotnet-sdk-31-2004
snapcraft snap
sudo snap install *.snap --dangerous --classic
popd

name="dotnet-hello"
pushd $name
snapcraft pull
lxc start snapcraft-$name
lxc file push ../dotnet-sdk-31-2004/*amd64.snap snapcraft-$name/tmp/sdk.snap
lxc exec snapcraft-$name  -- sudo snap install /tmp/sdk.snap --classic --dangerous
snapcraft snap
sudo snap install *.snap --dangerous
sudo snap connect $name:process-control
popd

name="dotnet-hello-using-dotnet-runtime-snap"
pushd $name
snapcraft pull
lxc start snapcraft-$name
lxc file push ../dotnet-sdk-31-2004/*amd64.snap snapcraft-dotnet-hello-using-dotnet-runtime-snap/tmp/sdk.snap
lxc exec snapcraft-$name  -- snap install /tmp/sdk.snap --classic --dangerous
snapcraft snap
sudo snap install *.snap --dangerous
sudo snap connect $name:dotnet-runtime-31-2004 dotnet-runtime-31
sudo snap connect $name:process-control
popd
