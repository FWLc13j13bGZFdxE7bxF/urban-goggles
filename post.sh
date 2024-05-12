#!/bin/bash

CHECKPOINT_MODELS=(
    "https://huggingface.co/maybent/a/resolve/main/132632--epicphotogasm/350416--epicphotogasm_ultimateFidelity.pruned.fp16.safetensors"
)

LORA_MODELS=(
    #"https://civitai.com/api/download/models/16576"
)

CONTROLNET_MODELS=(
    "https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_canny-fp16.safetensors"
    "https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_normal-fp16.safetensors"
    "https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_openpose-fp16.safetensors"
    "https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_seg-fp16.safetensors"
    "https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_depth-fp16.safetensors"
    "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_inpaint.pth"
    "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_inpaint.yaml"
)

VAE_MODELS=(
    "https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl.vae.safetensors"
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
    if [[ "$1" == *"/huggingface.co"* && "$HF_TOKEN" ]]; then
        wget -qnc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P "$2" --header "Authorization: Bearer $HF_TOKEN" "$1"
    else
        wget -qnc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P "$2" "$1"
    fi
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
    provisioning_get_models \
            "${WORKSPACE}/storage/stable_diffusion/models/vae" \
            "${VAE_MODELS[@]}"
}

start
