# vi: path=steps foldmarker=\ _{,\ _} foldmethod=marker
#
#      TODO: The book suggests to store these variabls
#            in /etc/profile.d/xorg.sh
#
export XORG_PREFIX=/usr
export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static"

export lfs_dir=/etc/lfs/
export lfs_download_dir=${lfs_dir}downloads/
export lfs_extract_dir=${lfs_dir}extracted

#
# TODO: This directory probably should also go under /etc/lfs somewhere.
#
export lfs_bootscript_dir=~/github/github/Linux-From-Scratch/blfs/bootscripts

umask 022

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


# V.2 lfs_log() { #_{
# V.2   local text="$1"
# V.2 # echo $text >> ${lfs_dir}log
# V.2 
# V.2   # Note: using UTF so that all log messages are consistent.
# V.2   printf "%s: %-20s %-32s %s\n" "$(TZ=UTF date +'%Y-%m-%d %H:%M:%S')" $lfs_cur_step_name ${FUNCNAME[1]}  "$text" >> ${lfs_dir}log
# V.2 } #_}
# V.2 export -f lfs_log

# V.2 lfs_start_step() { #_{
# V.2   trap 'echo Error in $lfs_cur_step_name at line $LINENO; exit 1' ERR
# V.2   lfs_log "Start step $lfs_cur_step_name, umask=$(umask)"
# V.2 } #_}
# V.2 export -f lfs_start_step

# V.2 lfs_end_step() { #_{
# V.2    return 0
# V.2 } #_}
# V.2 export -f lfs_end_step

lfs_download() { # _{

# trap 'return -1' ERR

  local download_url=$1
  local download_file_name=$(basename $download_url)

  lfs_log "download_url=$download_url, download_file_name=$download_file_name"

  #
  #  Download the file, if necessary
  #
  lfs_log "going to check wheather $lfs_download_dir$download_file_name already exists"
  if [ ! -f $lfs_download_dir$download_file_name ]; then
    lfs_log "downloading $download_url to $lfs_download_dir"
    if ! wget $download_url -P $lfs_download_dir; then
      local wget_exit_val=$?
      lfs_log "wget reported a problem downloading $download_url, \$? = $wget_exit_val"
      return 1
    fi

  else
    lfs_log "$download_file_name already downloaded"
  fi
} # _}
export -f lfs_download

lfs_download_and_extract() { # _{
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

  exit 1 # donloaded file must be moved to tarred directory
  lfs_untar TODO TODO
# use lfs_untar()  if [ ${download_file_name: -4} == '.zip' ]; then
# use lfs_untar()    local isZip=yes
# use lfs_untar()    local extracted_dir=$(basename $download_file_name .zip)
# use lfs_untar()    lfs_log "isZip, extracted_dir = $extracted_dir"
# use lfs_untar()  else
# use lfs_untar()    local isZip=no
# use lfs_untar()
# use lfs_untar()    local extracted_dir=$(basename $download_file_name .gz ) 
# use lfs_untar()          extracted_dir=$(basename $extracted_dir      .xz ) 
# use lfs_untar()          extracted_dir=$(basename $extracted_dir      .bz2) 
# use lfs_untar()          extracted_dir=$(basename $extracted_dir      .tar) 
# use lfs_untar()          extracted_dir=$(basename $extracted_dir      .tgz) 
# use lfs_untar()  fi
# use lfs_untar()
# use lfs_untar()  #
# use lfs_untar()  #  Extract the file, if necessary
# use lfs_untar()  #
# use lfs_untar()# lfs_log "Going to check whether extract dir $dest_dir/$extracted_dir exists"
# use lfs_untar()  if [ ! -d $dest_dir/$extracted_dir ]; then
# use lfs_untar()    lfs_log "Extraction directory $dest_dir/$extracted_dir does not exist"
# use lfs_untar()    if [ $isZip == yes ]; then
# use lfs_untar()    # TODO 2018-03-02: because of Noto-hinted.zip
# use lfs_untar()      lfs_log "unzip $lfs_download_dir$download_file_name to $dest_dir/$extracted_dir"
# use lfs_untar()      unzip  $lfs_download_dir$download_file_name -d $dest_dir/$extracted_dir > /dev/null
# use lfs_untar()    else
# use lfs_untar()    #
# use lfs_untar()    # Extract the downloaded file into an empty tmp directory first, so that
# use lfs_untar()    # we can make sure that the entire content of the tar file goes under
# use lfs_untar()    # $extracted_dir
# use lfs_untar()    #
# use lfs_untar()      rm -rf /tmp/lfs_extract_dir
# use lfs_untar()      mkdir  /tmp/lfs_extract_dir
# use lfs_untar()      if ! tar xf $lfs_download_dir$download_file_name -C /tmp/lfs_extract_dir; then
# use lfs_untar()        lfs_log "$lfs_download_dir$download_file_name does not seem to be a tar file"
# use lfs_untar()        echo "?"
# use lfs_untar()        return 1
# use lfs_untar()      fi
# use lfs_untar()      
# use lfs_untar()      lfs_log "mkdir $dest_dir/$extracted_dir"
# use lfs_untar()      mkdir $dest_dir/$extracted_dir
# use lfs_untar()
# use lfs_untar()      if [ $(ls /tmp/lfs_extract_dir | wc -l) == 1 ]; then
# use lfs_untar()        lfs_log "$download_file_name contains a directory"
# use lfs_untar()      # Subshell so that the effect of shopt -s dotglob is undone.
# use lfs_untar()      # shopt -s dotglob also matches dot files (but not . and .. )
# use lfs_untar()      ( shopt -s dotglob; mv /tmp/lfs_extract_dir/*/* $dest_dir/$extracted_dir )
# use lfs_untar()      # mv /tmp/lfs_extract_dir/*/.[!.]* $dest_dir/$extracted_dir
# use lfs_untar()      # mv /tmp/lfs_extract_dir/*/*  $dest_dir/$extracted_dir
# use lfs_untar()      # mv /tmp/lfs_extract_dir/*/.* $dest_dir/$extracted_dir
# use lfs_untar()      # pushd /tmp/lfs_extract_dir/*
# use lfs_untar()      #   mv *         $dest_dir/$extracted_dir
# use lfs_untar()      # #       .[!.]* -> https://askubuntu.com/a/259386/242303
# use lfs_untar()      #   mv -f .[!.]* $dest_dir/$extracted_dir
# use lfs_untar()      # popd
# use lfs_untar()      else
# use lfs_untar()        lfs_log "$download_file_name contains multiple files"
# use lfs_untar()        mv /tmp/lfs_extract_dir/* $dest_dir/$extracted_dir
# use lfs_untar()      fi
# use lfs_untar()
# use lfs_untar()    # tar xf $lfs_download_dir$download_file_name -C $dest_dir
# use lfs_untar()    fi
# use lfs_untar()  else
# use lfs_untar()    lfs_log "directory $dest_dir/$extracted_dir already exists"
# use lfs_untar()  fi

#
# This echo is necessary because this function is called
# via $(lfs_download_and_extract ... )
  echo "$dest_dir/$extracted_dir"

} # _}
export -f lfs_download_and_extract

lfs_download_extract_and_pushd() { # _{

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

} # _}
export -f lfs_download_extract_and_pushd

# V.2 lfs_patch() { # _{
# V.2   local patch_file=$lfs_download_dir$1
# V.2 
# V.2   if [ ! -r $patch_file ]; then
# V.2     lfs_log "patch file $patch_file is not readable"
# V.2     return 1
# V.2   fi
# V.2 
# V.2   lfs_log "Patching with patch file $patch_file in $PWD"
# V.2 
# V.2   patch -Np1 -i $patch_file
# V.2   return 0
# V.2 } # _}
# V.2 export -f lfs_patch

lfs_download_and_apply_patch() { #_{
  local download_url=$1

  lfs_log "downloding and apply patch: $download_url"
  lfs_download $download_url

  lfs_patch $(basename $download_url)

} #_}
export -f lfs_download_and_apply_patch

lfs_install_bootscript() { # _{
  local bootscript_name=$1

  if [ ! -d $lfs_bootscript_dir ]; then
    lfs_log "Bootscript directory $lfs_bootscript_dir does not exist"
    return 1
  fi

  pushd $lfs_bootscript_dir
    lfs_log "make install-$bootscript_name in $PWD"
    if ! make install-$bootscript_name; then
      local rc=$?
      lfs_log "make install-$bootscript_name returned $rc"
      return 1
    fi
  popd

  return 0
} # _}
export -f lfs_install_bootscript

lfs_check_kernel_config_param() { # _{
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
# _}
# V.2 lfs_take_fs_snapshot() { #_{
# V.2 
# V.2   local suffix=$1
# V.2 
# V.2   local out_file=${lfs_dir}fs_snapshots/$lfs_cur_step_name.$suffix
# V.2 
# V.2   if [ -e $out_file ]; then
# V.2     lfs_log "$out_file already exists, I am not overwriting it"
# V.2     return 0
# V.2   fi
# V.2 
# V.2 #        -path '/usr/lib/python2.7/*'     -prune -o \
# V.2 #        -path '/usr/lib/python3.6/*'     -prune -o \
# V.2 #        -path '/usr/lib/gconv'           -prune -o \
# V.2 #        -name '.git'                     -prune -o \
# V.2   find / -path '/proc'                    -prune -o \
# V.2          -path '/sources'                 -prune -o \
# V.2          -path '/dev'                     -prune -o \
# V.2          -path '/lfs'                     -prune -o \
# V.2          -path  ${lfs_dir%/}              -prune -o \
# V.2          -path '/sys'                     -prune -o \
# V.2          -path '/usr/include'             -prune -o \
# V.2          -path '/usr/lib/*'               -prune -o \
# V.2          -path '/usr/share'               -prune -o \
# V.2          -path '/tools/*/*'               -prune -o \
# V.2          -path '/lib/libreoffice/*'       -prune -o \
# V.2          -path '/opt/ant-*/manual'        -prune -o \
# V.2          -path '/opt/OpenJDK-*-bin/*'     -prune -o \
# V.2          -path '/root'                    -prune -o \
# V.2          -path '/boot/grub/*'             -prune -o \
# V.2          -path '/run/udev/*'              -prune -o \
# V.2          -path '/mnt'                     -prune -o \
# V.2          -print > $out_file
# V.2 
# V.2 }
# V.2 export -f lfs_take_fs_snapshot
# V.2 #_}

lfs_git_clone_and_pushd() { #_{

  local git_path=$1
  local dir=$(basename $git_path)

  lfs_log "git_path=$git_path / dir=$dir"

  cd /etc/lfs/git-sources/

  if [ -d $dir ]; then
    lfs_log "$dir exists"
  else
    git clone $git_path
  fi

#
#    rm possible .git at and of path
#   (github repos usually don't have such a .git ending in
#    order to be cloned).
#
  pushd ${dir%.git}
} #_}
export -f lfs_git_clone_and_pushd

lfs_x_step() { #_{

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

   
  lfs_take_fs_snapshot before

  pushd steps       > /dev/null
  ./$name
  popd              > /dev/null

  lfs_take_fs_snapshot after

  touch done/$name

  export lfs_cur_step_name='?'
} #_}

lfs_x_step which
lfs_x_step profile

lfs_x_step perl-archive-zip


lfs_x_step unzip                    # required to unzip *.zip files (?)
lfs_x_step zip                      # required for firefox


# TODO: FreeType2 should be named freetype2
lfs_x_step FreeType2                # required for fontconfig
lfs_x_step libxml                   # required for shared-mime-info, option for fontconfig
lfs_x_step fontconfig

lfs_x_step sgml-common
lfs_x_step sgml-dtd-3               # docbook 3.1
lfs_x_step sgml-dtd                 # docbook 4.5
lfs_x_step docbook                  # docbook-xml

lfs_x_step docbook-xsl              # 1st part of docbook-xsl

lfs_x_step libffi                   # required for glib
lfs_x_step pcre                     # required for glib

lfs_x_step glib                     # required for atk

lfs_x_step ntfs-3g

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

lfs_x_step lshw
lfs_x_step dmidecode

lfs_x_step libpng                   # required for Xorg-applications
lfs_x_step pixman                   # requried for Xorg-server

lfs_x_step libarchive               # optionally required by CMake
lfs_x_step CMake
lfs_x_step doxygen                  # requires CMake
lfs_x_step popt                     # required for rpm
lfs_x_step db                       # required for rpm
lfs_x_step lua
lfs_x_step rpm                      # requires popt

lfs_x_step libproxy

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

lfs_x_step  gpm                      # TODO: does it require glib?
lfs_x_step  rsync
lfs_x_step  vim

lfs_x_step  fonts

lfs_x_step  X-config-perms

lfs_x_step tcl                  # required for expect
lfs_x_step expect               # required for deja-gnu
lfs_x_step deja-gnu
lfs_x_step autoconf-2-13        # required for firefox

lfs_x_step libevent             # possibly required for firefox

lfs_x_step atk                  # required for gtk-2

# TODO libjpeg-turbo should be named libjpeg
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

lfs_x_step libglade
lfs_x_step libdaemon
lfs_x_step avahi

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
lfs_x_step mitkrb               # Kerberos
lfs_x_step sudo
lfs_x_step nettle               # required for gnu-tls
lfs_x_step gnu-tls              # required for cups
lfs_x_step hplib
lfs_x_step cups                 # runtime dependency of java

lfs_x_step giflib               # required for java-binary

lfs_x_step gutenprint

lfs_x_step babl


lfs_x_step java-binary          # required for ant
lfs_x_step java-conf            # recommended for ant
lfs_x_step ant

lfs_x_step apr                  # recommended for libre-office
lfs_x_step python3              # required for libre-office
lfs_x_step meson
lfs_x_step ninja
lfs_x_step json-glib
lfs_x_step gegl
lfs_x_step python-pycairo
lfs_x_step python-pygobject2
lfs_x_step python-pygtk
lfs_x_step gimp
lfs_x_step sane-backend
lfs_x_step sane-frontend
lfs_x_step gimp-help
lfs_x_step boost                # recommended for libre-office
lfs_x_step clucene              # recommended for libre-office
lfs_x_step dbus-glib            # recommended for libre-office

lfs_x_step gstreamer            # required for gst10-plugings-base

lfs_x_step gst10-plugins-base   # recommended for libre-office
lfs_x_step libatomic_ops        # recommended for libre-office
lfs_x_step lcms2                # recommended for libre-office and gs (Little CMS)
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
lfs_x_step alsa-plugins
lfs_x_step alsa-utils
lfs_x_step rust                 # required for firefox

lfs_x_step desktop-file-utils

lfs_x_step firefox
lfs_x_step thunderbird

lfs_x_step libreoffice

# lfs_x_step  one
# lfs_x_step  two
