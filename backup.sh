SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARENT_FOLDER="${SCRIPT_DIR}/projects/photonlang/Photon/out/bin/";

# Create an artifact for the release by ziping the release folder
cd ${PARENT_FOLDER};
zip -r photon.zip Release;
mv photon.zip ${SCRIPT_DIR};
