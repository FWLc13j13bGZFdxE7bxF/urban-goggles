#!/bin/bash

CHECKPOINT_MODELS=(
    # LazyMix+ v4.0-inpainting fp16
    "https://civitai.com/api/download/models/302254?type=Model&format=SafeTensor&size=full&fp=fp16"
    "https://civitai.com/api/download/models/429454?type=Model&format=SafeTensor&size=pruned&fp=fp16"
    "https://civitai.com/api/download/models/489217?type=Model&format=SafeTensor&size=pruned&fp=fp16"
)

SAM_MODELS=(
  "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth"
)

LORA_MODELS=(
    #"https://civitai.com/api/download/models/16576"
)

CONTROLNET_MODELS=(
    "https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_canny-fp16.safetensors"
    "https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_normal-fp16.safetensors"
    "https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_openpose-fp16.safetensors"
    "https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_seg-fp16.safetensors"
    "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_inpaint.pth"
    "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_inpaint.yaml"
)

function provisioning_get_models() {
    if [[ -z $2 ]]; then return 1; fi
    dir="$1"
    mkdir -p "$dir"
    shift
    if [[ $DISK_GB_ALLOCATED -ge $DISK_GB_REQUIRED ]]; then
        arr=("$@")
    else
        printf "WARNING: Low disk space allocation - Only the first model will be downloaded!\n"
        arr=("$1")
    fi
    
    printf "Downloading %s model(s) to %s...\n" "${#arr[@]}" "$dir"
    for url in "${arr[@]}"; do
        printf "Downloading: %s\n" "${url}"
        provisioning_download "${url}" "${dir}"
        printf "\n"
    done
}

# Download from $1 URL to $2 file path
function provisioning_download() {
    wget -qnc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P "$2" "$1"
}

function start() {
    source /opt/ai-dock/etc/environment.sh

    provisioning_get_models \
            "${WORKSPACE}/storage/stable_diffusion/models/ckpt" \
            "${CHECKPOINT_MODELS[@]}"
    provisioning_get_models \
            "${WORKSPACE}/storage/stable_diffusion/models/controlnet" \
            "${CONTROLNET_MODELS[@]}"
    provisioning_get_models \
            "${WORKSPACE}/storage/stable_diffusion/models/lora" \
            "${LORA_MODELS[@]}"
}

start
