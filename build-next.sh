SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$1" == "--compiler-only" ]; then
    echo "Building Compiler Only";
    cd "${SCRIPT_DIR}/projects/photonlang/Compiler";
    ph-next;
    exit 0;
else 
    cd "${SCRIPT_DIR}/projects/reusable/ArgumentParser";
    ph-next;
    cd "${SCRIPT_DIR}/projects/reusable/Logging";
    ph-next;
    cd "${SCRIPT_DIR}/projects/reusable/FileSystem"; 
    ph-next;
    cd "${SCRIPT_DIR}/projects/photonlang/Compiler";
    ph-next;
    cd "${SCRIPT_DIR}/projects/photonlang/Photon";
    ph-next;
fi

SOURCE_FOLDER="${SCRIPT_DIR}/projects/photonlang/Photon/out/bin/Debug/net7.0/";
TARGET_FOLDER="${SCRIPT_DIR}/projects/photonlang/Photon/out/bin/RC/";
IN_FILE="${SCRIPT_DIR}/projects/photonlang/Photon/out/bin/RC/net7.0/Photon";

mkdir -p ${TARGET_FOLDER};
cp -ar ${SOURCE_FOLDER} ${TARGET_FOLDER};

OUT_FILE="/usr/bin/ph-rc";

if [ -f "$OUT_FILE" ]; then
    echo "Photon RC Already Installed";
else
    echo "Installing";
    sudo ln -s ${IN_FILE} ${OUT_FILE};
fi
