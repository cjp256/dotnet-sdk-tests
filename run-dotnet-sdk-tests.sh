#!/bin/bash -ex

dotnet="/snap/bin/dotnet-sdk.dotnet"
rm -rf apptest

# Create .NET sample project "apptest".
$dotnet new console -n apptest

# Build project.
$dotnet build apptest

# Run project using `dotnet run`.
$dotnet run --project apptest

# Run project using built "dll" via `dotnet`.
$dotnet ./apptest/bin/Debug/netcoreapp3.1/apptest.dll

# Run project using built binary.  Requires:
# (1) DOTNET_ROOT for 'Process terminated. Couldn't find a valid ICU package installed on the system. Set the configuration flag System.Globalization.Invariant to true if you want to run with no globalization support.'
# (2) LD_LIBRARY_PATH for 'A fatal error occurred. The required library libhostfxr.so could not be found.'
LD_LIBRARY_PATH=/snap/dotnet-sdk/current/usr/lib/x86_64-linux-gnu DOTNET_ROOT=/snap/dotnet-sdk/current ./apptest/bin/Debug/netcoreapp3.1/apptest

# Publish self-contained build.
$dotnet publish apptest  --self-contained -r linux-x64

# Run self-contained build binary.
./apptest/bin/Debug/netcoreapp3.1/linux-x64/publish/apptest

# Run self-contained "dll" via `dotnet`.
$dotnet ./apptest/bin/Debug/netcoreapp3.1/linux-x64/publish/apptest.dll
