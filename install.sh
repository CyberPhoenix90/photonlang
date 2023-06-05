SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TARGET_FOLDER="${SCRIPT_DIR}/projects/photonlang/Photon/out/bin/";

mkdir -p ${TARGET_FOLDER};

# Extract the release artifact
unzip photon.zip -d ${TARGET_FOLDER};

OUT_FILE="/usr/bin/ph";
IN_FILE="${SCRIPT_DIR}/projects/photonlang/Photon/out/bin/Release/net7.0/Photon";

if [ -f "$OUT_FILE" ]; then
    echo "Photon CLI Already Installed";
else
    echo "Installing";
    sudo ln -s ${IN_FILE} ${OUT_FILE};
fi
