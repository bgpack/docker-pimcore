#!/bin/bash
set -e

# taskfile.sh: Normalize and streamline Docker image build tasks.

# Functions

# Create gzipped tarball of files
create_gz_file() {
    local working_path=$1
    local folder_name=$2
    local output_file=$3
    local full_output_path="$working_path/$output_file"
    echo $working_path
    echo $folder_name
    echo $output_file
    echo $full_output_path
    [ ! -e "$full_output_path" ] || rm "$full_output_path"
    cd "$working_path/$folder_name" && GZIP=-n gtar --sort=name -czvf "../$output_file" * --owner=0 --group=0
    cd ../../..
    shasum "$full_output_path"
}

# Remove gzipped tarball of files
remove_gz_file() {
    local file=$1
    [ -e "$file" ] && rm "$file"
}

# Build Docker image
build_docker_image() {
    local push_load_option_argument=$1
    local target=$2
    local tag=$3
    local context=$4
    local latest_tag=$5
    local secret=$6
    local platform=${7:-"linux/$(arch | sed 's/x86_64/amd64/')"}
    tag+=-`echo $platform|sed 's/linux\///'`
    src="$context/$secret"
    echo "########################## push_load_option_argument"
    echo $push_load_option_argument
    echo "########################## target"
    echo $target
    echo "########################## tag"
    echo $tag
    echo "########################## context"
    echo $context
    echo "########################## latest_tag"
    echo $latest_tag
    echo "########################## secret"
    echo $secret
    echo "########################## platform"
    echo $platform
    echo "##########################"
    cd docker && docker buildx build \
        $push_load_option_argument \
         --no-cache \
        --platform "$platform" \
        --target "$target" \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --secret id="$secret",src="$context/$secret" \
        --cache-from "$latest_tag" \
        -t "$tag" \
        "$context"
}

# push Docker image
push_docker_image() {
    local tag=$1
    local platform=${2:-"linux/$(arch | sed 's/x86_64/amd64/')"}
    if [[ "$platform" == *,* ]]; then
        # Do nothing if platform is a comma-separated list
        :
    else
        tag+="-$(arch | sed 's/x86_64/amd64/')"
    fi

    docker push "$tag"
}

"$@"