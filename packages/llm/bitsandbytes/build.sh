#!/usr/bin/env bash
set -ex

echo " ================ Building bitsandbytes ${BITSANDBYTES_VERSION} ================"

echo "### CUDA_INSTALLED_VERSION: $CUDA_INSTALLED_VERSION" 
echo "### CUDA_MAKE_LIB: $CUDA_MAKE_LIB" 
pip3 uninstall -y bitsandbytes || echo "previous bitsandbytes installation not found"

git clone --depth=1 --branch=$BITSANDBYTES_BRANCH "https://github.com/$BITSANDBYTES_REPO" /opt/bitsandbytes

CUDA_VERSION=$CUDA_INSTALLED_VERSION make -C /opt/bitsandbytes -j$(nproc) "${CUDA_MAKE_LIB}"
CUDA_VERSION=$CUDA_INSTALLED_VERSION make -C /opt/bitsandbytes -j$(nproc) "${CUDA_MAKE_LIB}_nomatmul"

cd /opt/bitsandbytes
python3 setup.py --verbose build_ext --inplace -j$(nproc) bdist_wheel --dist-dir /opt 
ls -l /opt/ 
pip3 install --no-cache-dir --verbose scipy 
pip3 install --no-cache-dir --verbose /opt/bitsandbytes*.whl

twine upload --verbose /opt/bitsandbytes*.whl || echo "failed to upload wheel to ${TWINE_REPOSITORY_URL}"
