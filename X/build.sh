#
#      TODO: The book suggests to store these variabls
#            in /etc/profile.d/xorg.sh
#
export XORG_PREFIX=/usr
export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static"

export lfs_dir=/etc/lfs
export lfs_download_dir=${lfs_dir}/downloads
export lfs_extract_dir=${lfs_dir}/extracted

if [ ! -d done ]; then
   mkdir 'done' # Without quote: syntax highlighting is really annoying
fi
if [ ! -d steps ]; then
   mkdir steps
fi
if [ ! -d downloads ]; then
   mkdir downloads
fi

# Zero tolerance
trap 'exit 1' ERR


lfs_log() {
  local text="$1"
# echo $text >> $lfs_dir/log

  # Note: using UTF so that all log messages are consistent.
  printf "%s: %-20s %-32s %s\n" "$(TZ=UTF date +'%Y-%m-%d %H:%M:%S')" $lfs_cur_step_name ${FUNCNAME[1]}  "$text" >> $lfs_dir/log
}
export -f lfs_log

lfs_start_step() {
  trap 'echo Error at line $LINENO; exit 1' ERR
}
export -f lfs_start_step

lfs_end_step() {
   return 0
}
export -f lfs_end_step

lfs_download() {

  trap 'return -1' ERR

  local download_url=$1
  local download_file_name=$(basename $download_url)

  lfs_log "download_url=$download_url, download_file_name=$download_file_name"


  #
  #  Download the file, if necessary
  #
  lfs_log "going to check wheather $lfs_download_dir/$download_file_name already exists"
  if [ ! -f $lfs_download_dir/$download_file_name ]; then
    lfs_log "downloading $download_file_name to $lfs_download_dir"
    wget $download_url -P $lfs_download_dir
    lfs_log "wget: \$?=$?"
  else
    lfs_log "$download_file_name already downloaded"
  fi
}
export -f lfs_download

lfs_download_and_extract() {
  local download_url=$1
# local dest_dir=$2
  local dest_dir=$lfs_extract_dir

  lfs_log "lfs_download_and_extract called, download_url = $download_url"

  if [ -z "$dest_dir" ]; then
    lfs_log "lfs_download_and_extract: $dest_dir is zero"
    return 1
  fi

  if [ ! -d "$dest_dir" ]; then
    lfs_log "lfs_download_and_extract: dest dir $dest_dir does not exist"
    return 1
  fi


  lfs_download $download_url

  local download_file_name=$(basename $download_url)
  #
  #  Find last part of downloaded file
  #
  local extracted_dir=$(basename $download_file_name .gz ) 
        extracted_dir=$(basename $extracted_dir      .bz2) 
        extracted_dir=$(basename $extracted_dir      .tar) 

  #
  #  Extract the file, if necessary
  #
  if [ ! -d $dest_dir/$extracted_dir ]; then
    lfs_log "trying to untar $lfs_download_dir/$extracted_dir into $dest_dir, PWD=$PWD"
    tar xf $lfs_download_dir/$download_file_name -C $dest_dir
  else
    lfs_log directory $dest_dir/$extracted_dir already exists
  fi

  echo "$dest_dir/$extracted_dir"

}
export -f lfs_download_and_extract

lfs_download_extract_and_pushd() {
  local download_url=$1
# local dest_dir=$lfs_extract_dir  # Was: $2

  lfs_log "lfs_download_extract_and_pushd called, download_url = $download_url" # , dest_dir = $dest_dir"

  local extracted_dir=$(lfs_download_and_extract $download_url) #  $dest_dir)

  if [[ -z $extracted_dir ]]; then
    lfs_log "lfs_download_extract_and_pushd: extracted_dir is zero"
    return -1
  fi
  lfs_log "lfs_download_extract_and_pushd: extracted_dir=$extracted_dir, pushd into it"
  pushd $extracted_dir

}
export -f lfs_download_extract_and_pushd

lfs_x_step() {

  trap 'echo Error at line $LINENO; exit 1' ERR

  local name=$1
  export lfs_cur_step_name=$name

  if [ -e done/$name ]; then
    lfs_log "lfs_x_step: $name already done"
    return 0
  fi

  if [ ! -e steps/$name ]; then
     lfs_log "lfs_x_step: steps/$name does not exist"
     return 1
  fi


#  pushd steps/$name > /dev/null
   ./steps/$name
#  ./go
#  popd              > /dev/null

  touch done/$name

  export lfs_cur_step_name='?'
}

# TODO: Fix  util-macros
#       and protocol-headers
#       Especially the handling of the download directories.

lfs_x_step  util-macros
lfs_x_step  protocol-headers
#

lfs_x_step  libXau
lfs_x_step  libXdmcp



