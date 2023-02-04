SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "${SCRIPT_DIR}/projects/reusable/ArgumentParser";
ph-next;
cd "${SCRIPT_DIR}/projects/reusable/Logging";
ph-rc;
cd "${SCRIPT_DIR}/projects/reusable/FileSystem"; 
ph-rc;
cd "${SCRIPT_DIR}/projects/photonlang/Compiler";
ph-rc;
cd "${SCRIPT_DIR}/projects/photonlang/Photon";
ph-rc;

