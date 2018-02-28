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
  trap 'echo Error in $lfs_cur_step_name at line $LINENO; exit 1' ERR
}
export -f lfs_start_step

lfs_end_step() {
   return 0
}
export -f lfs_end_step

lfs_download() {

# trap 'return -1' ERR

  local download_url=$1
  local download_file_name=$(basename $download_url)

  lfs_log "download_url=$download_url, download_file_name=$download_file_name"


  #
  #  Download the file, if necessary
  #
  lfs_log "going to check wheather $lfs_download_dir/$download_file_name already exists"
  if [ ! -f $lfs_download_dir/$download_file_name ]; then
    lfs_log "downloading $download_url to $lfs_download_dir"
    wget $download_url -P $lfs_download_dir
  else
    lfs_log "$download_file_name already downloaded"
  fi
}
export -f lfs_download

lfs_download_and_extract() {
  local download_url=$1
# local dest_dir=$2
  local dest_dir=$lfs_extract_dir

# trap 'return -1' ERR


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
        extracted_dir=$(basename $extracted_dir      .xz ) 
        extracted_dir=$(basename $extracted_dir      .bz2) 
        extracted_dir=$(basename $extracted_dir      .tar) 

  #
  #  Extract the file, if necessary
  #
  lfs_log "Going to check whether extract dir $dest_dir/$extracted_dir exists"
  if [ ! -d $dest_dir/$extracted_dir ]; then
    lfs_log "Directory does not exist, trying to untar $lfs_download_dir/$extracted_dir into $dest_dir, PWD=$PWD"
    if [ ! -d $dest/$extracted_dir ]; then
       lfs_log "! $dest/$extracted_dir is not a directory"
    fi
    tar xf $lfs_download_dir/$download_file_name -C $dest_dir
  else
    lfs_log "directory $dest_dir/$extracted_dir already exists"
  fi

  echo "$dest_dir/$extracted_dir"

}
export -f lfs_download_and_extract

lfs_download_extract_and_pushd() {
# trap 'return -1' ERR

  local download_url=$1
# local dest_dir=$lfs_extract_dir  # Was: $2


  local extracted_dir=$(lfs_download_and_extract $download_url) #  $dest_dir)

  if [[ -z $extracted_dir ]]; then
    lfs_log "extracted_dir is zero"
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
    lfs_log "already done: $name"
    return 0
  fi

  if [ ! -e steps/$name ]; then
     lfs_log "step $name does not exist, PWD=$PWD"
     return 1
  fi


   pushd steps       > /dev/null
   ./$name
#  ./go
   popd              > /dev/null

  touch done/$name

  export lfs_cur_step_name='?'
}

lfs_x_step FreeType2     # required for fontconfig
lfs_x_step fontconfig    # required for Xorg



lfs_x_step MarkupSafe    # required for beaker
lfs_x_step funcsigs      # required for beaker
lfs_x_step beaker        # required for mako
lfs_x_step mako          # required for mesa

lfs_x_step libpng        # required for Xorg-applications
lfs_x_step pixman        # requried for Xorg-server


# TODO: Fix  util-macros
#       and protocol-headers
#       Especially the handling of the download directories.

lfs_x_step  util-macros
lfs_x_step  protocol-headers
#

lfs_x_step  libXau
lfs_x_step  libXdmcp
lfs_x_step  xcb-proto
lfs_x_step  libxcb
lfs_x_step  Xorg-libraries
lfs_x_step  xcb-util
lfs_x_step  xcb-util-image
lfs_x_step  xcb-util-keysyms
lfs_x_step  xcb-util-renderutil
lfs_x_step  xcb-util-wm
lfs_x_step  xcb-util-cursor

lfs_x_step  libdrm        # required for mesa
lfs_x_step  mesa
lfs_x_step  libepoxy      # requries mesa

lfs_x_step  xbitmaps
lfs_x_step  Xorg-applications
lfs_x_step  xcursor-themes
lfs_x_step  Xorg-fonts
lfs_x_step  XKeyboardConfig
lfs_x_step  Xorg-server      # optional requirement: libepoxy

lfs_x_step  Xorg-drv-libevdev
lfs_x_step  Xorg-drv-evdev
lfs_x_step  Xorg-drv-libinput
lfs_x_step  Xorg-drv-libinput-driver
# lfs_x_step  Xorg-drv-synaptics-driver
# lfs_x_step  Xorg-drv-vmmouse
# lfs_x_step  Xorg-drv-wacom
lfs_x_step  Xorg-drv-fbdev
lfs_x_step  Xorg-drv-intel
lfs_x_step  Xorg-drv-libva
lfs_x_step  Xorg-drv-libva-intel
lfs_x_step  Xorg-drv-libvdpau-va-gl

# lfs_x_step  one
# lfs_x_step  two
