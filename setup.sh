#!/bin/bash
bucket_name="aws-fpga-clean-eval-test"
result_folder_name="dma_read_write_result"
export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2
export AWS_DEFAULT_REGION=us-east-1
i=$3

echo "Start setup environment"

echo "SDK setup"
source sdk_setup.sh | tail -n 4

echo "Update AWS CLI"
pip install --upgrade --user awscli

echo "Describe image"
sudo fpga-describe-local-image -S 0
echo "Load image"
sudo fpga-load-local-image -S 0 -I agfi-0b5c35827af676702

echo "Compile test"
cd ./hdk/cl/examples/cl_dram_dma
export CL_DIR=$(pwd)
cd $CL_DIR/software/runtime/
make all

echo "Run first read_write test"
sudo ./test_dram_dma > "init_result_$i.txt"
echo "Clear and reload image"
sudo fpga-clear-local-image  -S 0
echo "Load image"
sudo fpga-load-local-image -S 0 -I agfi-0b5c35827af676702
echo "Run second read_write test"
sudo ./test_dram_dma > "reload_result_$i.txt"
aws s3 cp init_result_$i.txt s3://$bucket-name/$result_folder_name/
aws s3 cp reload_result_$i.txt s3://$bucket-name/$result_folder_name/
echo "Finish test"