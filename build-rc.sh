SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$1" == "--compiler-only" ]; then
    echo "Building Compiler Only";
    cd "${SCRIPT_DIR}/projects/photonlang/Compiler";
    ph-rc;
    exit 0;
else 
    cd "${SCRIPT_DIR}/projects/reusable/ArgumentParser";
    ph-rc;
    cd "${SCRIPT_DIR}/projects/reusable/Logging";
    ph-rc;
    cd "${SCRIPT_DIR}/projects/reusable/FileSystem"; 
    ph-rc;
    cd "${SCRIPT_DIR}/projects/photonlang/Compiler";
    ph-rc;
    cd "${SCRIPT_DIR}/projects/photonlang/Photon";
    ph-rc;
fi