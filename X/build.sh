# vi: path=steps
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
    if ! wget $download_url -P $lfs_download_dir; then
      local wget_exit_val=$?
      lfs_log "wget reported a problem downloading $download_url, \$? = $wget_exit_val"
      return 1
    fi

  else
    lfs_log "$download_file_name already downloaded"
  fi
}
export -f lfs_download

lfs_download_and_extract() {
  local download_url=$1
  local dest_dir=$lfs_extract_dir

  if [ -z "$dest_dir" ]; then
    lfs_log "$dest_dir is zero"
    return 1
  fi

  if [ ! -d "$dest_dir" ]; then
    lfs_log "dest dir $dest_dir does not exist"
    return 1
  fi


  if ! lfs_download $download_url; then
    lfs_log "Apparently, $download_url could not be downloaded"
    echo "?"
    return 1
  fi

  local download_file_name=$(basename $download_url)
  #
  #  Find last part of downloaded file
  #

  if [ ${download_file_name: -4} == '.zip' ]; then
    local isZip=yes
    local extracted_dir=$(basename $download_file_name .zip)
  else
    local isZip=no

    local extracted_dir=$(basename $download_file_name .gz ) 
          extracted_dir=$(basename $extracted_dir      .xz ) 
          extracted_dir=$(basename $extracted_dir      .bz2) 
          extracted_dir=$(basename $extracted_dir      .tar) 
          extracted_dir=$(basename $extracted_dir      .tgz) 
  fi

  #
  #  Extract the file, if necessary
  #
# lfs_log "Going to check whether extract dir $dest_dir/$extracted_dir exists"
  if [ ! -d $dest_dir/$extracted_dir ]; then
    lfs_log "Extraction directory $dest_dir/$extracted_dir does not exist"
    if [ $isZip == yes ]; then
    # TODO 2018-03-02: because of Noto-hinted.zip
      unzip  $lfs_download_dir/$download_file_name -d $dest_dir/$extracted_dir
    else
    #
    # Extract the downloaded file into an empty tmp directory first, so that
    # we can make sure that the entire content of the tar file goes under
    # $extracted_dir
    #
      rm -rf /tmp/lfs_extract_dir
      mkdir  /tmp/lfs_extract_dir
      if ! tar xf $lfs_download_dir/$download_file_name -C /tmp/lfs_extract_dir; then
        lfs_log "$lfs_download_dir/$download_file_name does not seem to be a tar file"
	echo "?"
	return 1
      fi
      
      lfs_log "mkdir $dest_dir/$extracted_dir"
      mkdir $dest_dir/$extracted_dir

      if [ $(ls /tmp/lfs_extract_dir | wc -l) == 1 ]; then
        lfs_log "$download_file_name contains a directory"
      # Subshell so that the effect of shopt -s dotglob is undone.
      # shopt -s dotglob also matches dot files (but not . and .. )
      ( shopt -s dotglob; mv /tmp/lfs_extract_dir/*/* $dest_dir/$extracted_dir )
      # mv /tmp/lfs_extract_dir/*/.[!.]* $dest_dir/$extracted_dir
      # mv /tmp/lfs_extract_dir/*/*  $dest_dir/$extracted_dir
      # mv /tmp/lfs_extract_dir/*/.* $dest_dir/$extracted_dir
      # pushd /tmp/lfs_extract_dir/*
      #   mv *         $dest_dir/$extracted_dir
      # #       .[!.]* -> https://askubuntu.com/a/259386/242303
      #   mv -f .[!.]* $dest_dir/$extracted_dir
      # popd
      else
        lfs_log "$download_file_name contains multiple files"
	mv /tmp/lfs_extract_dir/* $dest_dir/$extracted_dir
      fi


    # tar xf $lfs_download_dir/$download_file_name -C $dest_dir
    fi
  else
    lfs_log "directory $dest_dir/$extracted_dir already exists"
  fi

#
# This echo is necessary because this function is called
# via $(lfs_download_and_extract ... )
  echo "$dest_dir/$extracted_dir"

}
export -f lfs_download_and_extract

lfs_download_extract_and_pushd() {

  local download_url=$1

  local extracted_dir=$(lfs_download_and_extract $download_url) #  $dest_dir)

  if [[ -z $extracted_dir ]]; then
    lfs_log "extracted_dir is zero"
    return 1
  fi
  if [ $extracted_dir = "?" ]; then
    lfs_log "extracted_dir = ? which indicates an error"
    return 1
  fi
  lfs_log "lfs_download_extract_and_pushd: extracted_dir=$extracted_dir, pushd into it"
  pushd $extracted_dir

}
export -f lfs_download_extract_and_pushd

lfs_check_kernel_config_param() {
  local param=$1


# Function can be called with CONFIG_XYZ or just XYZ
  param=CONFIG_${param#CONFIG_}

  local value=$(gunzip < /proc/config.gz | grep "\\<$param\\>")
  lfs_log "Checking parameter $param, value is $value"

  if [ "$value" == "$param=y" ]; then
    echo "$param is set to y, returning 0"
    return 0
  fi

  echo "$param is not set to y, returning 1"

  return 1
}
export -f lfs_check_kernel_config_param

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
   popd              > /dev/null

  touch done/$name

  export lfs_cur_step_name='?'
}

lfs_x_step which

lfs_x_step perl-archive-zip

lfs_x_step unzip                    # required to unzip *.zip files (?)
lfs_x_step zip                      # required for firefox


lfs_x_step FreeType2                # required for fontconfig
lfs_x_step libxml                   # required for shared-mime-info, option for fontconfig
lfs_x_step fontconfig

lfs_x_step libffi                   # required for glib
lfs_x_step pcre                     # required for glib

lfs_x_step glib                     # required for atk

lfs_x_step gobject-introspection    # recommened for librsvg
lfs_x_step vala                     # recommened for librsvg

lfs_x_step icu                      # required for harfbuzz

lfs_x_step graphite-fonts           # required for graphite2
lfs_x_step graphite2                # recommended for libre-office
lfs_x_step harfbuzz                 # required for pango, for libre office, harfbuzz apparently needs to be built with graphite

lfs_x_step MarkupSafe               # required for beaker
lfs_x_step funcsigs                 # required for beaker
lfs_x_step beaker                   # required for mako
lfs_x_step mako                     # required for mesa

lfs_x_step libedit                  # option for sqlite
lfs_x_step sqlite

lfs_x_step libpng                   # required for Xorg-applications
lfs_x_step pixman                   # requried for Xorg-server

lfs_x_step libarchive               # optionally required by CMake
lfs_x_step CMake

lfs_x_step fribidi                  # required by libass
lfs_x_step libass                   # optionally required by ffmpeg
lfs_x_step fdk-aac                  # optionally required by ffmpeg
lfs_x_step LAME                     # optionally required by ffmpeg

lfs_x_step libogg                   # required by libtheora
lfs_x_step libvorbis                # optionally required by ffmpeg

lfs_x_step libtheora                # optionally required by ffmpeg

lfs_x_step yasm                     # optionally required by ffmpeg, required by libvpx
lfs_x_step libvpx                   # optionally required by ffmpeg
lfs_x_step opus                     # optionally required by ffmpeg
lfs_x_step x264                     # optionally required by ffmpeg
lfs_x_step x265                     # optionally required by ffmpeg
lfs_x_step ffmpeg

lfs_x_step mtdev                    # Apparently required for Xorg-drv-evdev

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
lfs_x_step  Xorg-drv-evdev               # Seems to require mtdev
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

lfs_x_step  twm # TODO really used
lfs_x_step  xterm
lfs_x_step  xclock
lfs_x_step  xinit

lfs_x_step  X-config

lfs_x_step  fonts

lfs_x_step  X-config-perms

lfs_x_step tcl                  # required for expect
lfs_x_step expect               # required for deja-gnu
lfs_x_step deja-gnu
lfs_x_step autoconf-2-13        # required for firefox

lfs_x_step libevent             # possibly required for firefox

lfs_x_step atk                  # required for gtk-2

lfs_x_step libjpeg-turbo        # required for gdk-pixbuf
lfs_x_step shared-mime-info     # required for gdk-pixbuf
lfs_x_step glu                  # option for freeglut
lfs_x_step freeglut             # option for gdk-pixbuf
lfs_x_step libtiff              # required for gdk-pixbuf
lfs_x_step jasper               # option for gdk-pixbuf

lfs_x_step gdk-pixbuf           # required for gtk-2
lfs_x_step cairo                # recommended for pango
lfs_x_step pango                # required for gtk-2

lfs_x_step gtk-2                # required for firefox

lfs_x_step dbus                 # required for at-spi-core
lfs_x_step at-spi-core          # required for at-spi-atk
lfs_x_step at-spi-atk           # required for gtk-3
lfs_x_step gtk-3                # required for firefox

lfs_x_step nspr                 # required for nss

lfs_x_step nss                  # required for firefox

lfs_x_step json-c               # required for pulse-audio
lfs_x_step libsndfile           # required for pulse-audio

lfs_x_step alsa-lib             # recommended for pulse-audio, runtime dependency of java
lfs_x_step fftw                 # recommended for pulse-audio
lfs_x_step libsamplerate        # recommended for pulse-audio

lfs_x_step libunistring
lfs_x_step libtasn
lfs_x_step p11-kit
lfs_x_step nettle               # required for gnu-tls
lfs_x_step gnu-tls              # required for cups
lfs_x_step hplib
lfs_x_step cups                 # runtime dependency of java

lfs_x_step giflib               # required for java-binary

lfs_x_step gutenprint

lfs_x_step java-binary          # required for ant
lfs_x_step java-conf            # recommended for ant
lfs_x_step ant

lfs_x_step apr                  # recommended for libre-office
lfs_x_step python3              # required for libre-office
lfs_x_step boost                # recommended for libre-office
lfs_x_step clucene              # recommended for libre-office
lfs_x_step dbus-glib            # recommended for libre-office

lfs_x_step gstreamer            # required for gst10-plugings-base

lfs_x_step gst10-plugins-base   # recommended for libre-office
lfs_x_step libatomic_ops        # recommended for libre-office
lfs_x_step lcms2                # recommended for libre-office (Little CMS)
lfs_x_step openjpeg             # required for poppler
lfs_x_step openjpeg2
lfs_x_step libcroco             # required for librsvg
lfs_x_step librsvg              # recommended for libre-office
lfs_x_step libxslt              # recommended for libre-office
lfs_x_step neon                 # recommended for libre-office
# lfs_x_step openldap             # recommended for libre-office
lfs_x_step poppler              # recommended for libre-office

lfs_x_step qpdf                 # required for cups-filters
lfs_x_step mupdf                # required for cups-filters
lfs_x_step ijs                  # required for cups-filters
lfs_x_step gs                   # required for cups-filters (ghostscript)
lfs_x_step cups-filters         # required for cups (postinstall)
lfs_x_step postgresql           # required for libre-office
lfs_x_step raptor               # required for rasqal
lfs_x_step rasqal               # required for redland
lfs_x_step redland              # required for libre-office
lfs_x_step ssconf               # required for serf
lfs_x_step apr-util             # required for serf
lfs_x_step serf                 # required for libre-office
# lfs_x_step unixodbc             # required for libre-office

lfs_x_step pulse-audio          # required for firefox
lfs_x_step rust                 # required for firefox

lfs_x_step desktop-file-utils

lfs_x_step firefox

lfs_x_step libreoffice

# lfs_x_step  one
# lfs_x_step  two
