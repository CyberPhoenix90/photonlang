SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "${SCRIPT_DIR}/projects/reusable/Logging";
ph-next;
cd "${SCRIPT_DIR}/projects/reusable/FileSystem"; 
ph-next;
cd "${SCRIPT_DIR}/projects/photonlang/Compiler";
ph-next;
cd "${SCRIPT_DIR}/projects/photonlang/Photon";
ph-next;

IN_FILE="${SCRIPT_DIR}/projects/photonlang/Photon/out/bin/Debug/net6.0/Photon";
OUT_FILE="/usr/bin/ph-next";

if [ -f "$OUT_FILE" ]; then
    echo "Photon Already Installed";
else
    echo "Installing";
    sudo ln -s ${IN_FILE} ${OUT_FILE};
fi
