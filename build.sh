set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# check if --compiler-only flag is set
if [ "$1" == "--compiler-only" ]; then
    echo "Building Compiler Only";
    cd "${SCRIPT_DIR}/projects/photonlang/Compiler";
    ph;
    exit 0;
else 
    cd "${SCRIPT_DIR}/projects/reusable/ArgumentParser";
    ph;
    cd "${SCRIPT_DIR}/projects/reusable/Logging";
    ph;
    cd "${SCRIPT_DIR}/projects/reusable/FileSystem"; 
    ph;
    cd "${SCRIPT_DIR}/projects/photonlang/Compiler";
    ph;
    cd "${SCRIPT_DIR}/projects/photonlang/Photon";
    ph;
fi



SOURCE_FOLDER="${SCRIPT_DIR}/projects/photonlang/Photon/out/bin/Debug/net8.0/";
TARGET_FOLDER="${SCRIPT_DIR}/projects/photonlang/Photon/out/bin/Next/";
IN_FILE="${SCRIPT_DIR}/projects/photonlang/Photon/out/bin/Next/net8.0/Photon";

mkdir -p ${TARGET_FOLDER};
cp -ar ${SOURCE_FOLDER} ${TARGET_FOLDER};

OUT_FILE="/usr/bin/ph-next";

if [ -f "$OUT_FILE" ]; then
    echo "Photon Already Installed";
else
    echo "Installing";
    sudo ln -s ${IN_FILE} ${OUT_FILE};
fi
