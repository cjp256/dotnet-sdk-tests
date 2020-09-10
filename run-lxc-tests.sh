#!/bin/bash -ex

sdk_snap=$1
DOTNET_SDK_SNAP=${sdk_snap:=dotnet-sdk_3.1.402_amd64.snap}

FEDORA32_INSTANCE=${FEDORA32_INSTANCE:=test-f32}
UBUNTU1604_INSTANCE=${UBUNTU1604_INSTANCE:=test-ubu1604}
UBUNTU1804_INSTANCE=${UBUNTU1804_INSTANCE:=test-ubu1804}
UBUNTU2004_INSTANCE=${UBUNTU2004_INSTANCE:=test-ubu2004}

function lxc_exec() {
    instance=$1
    shift
    lxc exec ${instance} -- "$@"
}

function setup_fedora() {
    instance=$1
    lxc_exec ${instance} dnf install -y snapd fuse squashfuse
    lxc_exec ${instance} ln -s /var/lib/snapd/snap /snap
    lxc_exec ${instance} sed -i '$aPATH=/var/lib/snapd/snap/bin:${PATH}' /etc/profile
    lxc stop ${instance}
    lxc start ${instance}
}

function delete_instance() {
    instance=$1
    lxc delete --force ${instance}
}

function create_instance() {
    image=$1
    instance=$2

    if lxc info ${instance} >/dev/null 2>&1; then
        delete_instance ${instance}
    fi

    lxc launch -v $image ${instance}

    # Make sure networking is ready.
    lxc_exec ${instance} systemctl restart systemd-networkd
}

function run_tests() {
    instance=$1
    lxc_exec ${instance} systemctl restart snapd
    lxc_exec ${instance} snap wait system seed.loaded
    lxc_exec ${instance} snap install snapcraft --classic
    lxc_exec ${instance} rm -rf /tmp/tests
    lxc_exec ${instance} mkdir /tmp/tests
    lxc file push ${DOTNET_SDK_SNAP} ${instance}/tmp/tests/
    lxc file push run-dotnet-sdk-tests.sh ${instance}/tmp/tests/
    lxc_exec ${instance} snap install /tmp/tests/$(basename ${DOTNET_SDK_SNAP}) --dangerous --classic
    lxc_exec ${instance} /tmp/tests/run-dotnet-sdk-tests.sh
    delete_instance ${instance}
}

create_instance ubuntu:16.04 ${UBUNTU1604_INSTANCE}
run_tests ${UBUNTU1604_INSTANCE}

create_instance ubuntu:18.04 ${UBUNTU1804_INSTANCE}
run_tests ${UBUNTU1804_INSTANCE}

create_instance ubuntu:20.04 ${UBUNTU2004_INSTANCE}
run_tests ${UBUNTU2004_INSTANCE}

create_instance images:fedora/32 ${FEDORA32_INSTANCE}
setup_fedora ${FEDORA32_INSTANCE}
run_tests ${FEDORA32_INSTANCE}

echo "ALL TESTS PASSED!"
