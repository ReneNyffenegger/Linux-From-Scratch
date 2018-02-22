#
#      TODO: The book suggests to store these variabls
#            in /etc/profile.d/xorg.sh
#
export XORG_PREFIX=/usr
export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static"

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

xls_x_step() {

  trap 'echo Error at line $LINENO; exit 1' ERR

  local name=$1
  local download_url=$2

  if [ -e done/$name ]; then
    echo "$name already done"
    return 0
  fi

  local download_file_name=$(basename $download_url)
  echo "Downloading $download_file_name"

  #
  #  Download the file, if necessary
  #
  if [ ! -f downloads/$download_file_name ]; then
    echo downloading $download_file_name
    wget $download_url -P downloads
  else
    echo $download_file_name already downloaded
  fi


  #
  #  Find last part of downloaded file
  #
  local extracted_dir=$(basename $download_file_name .gz ) 
        extracted_dir=$(basename $extracted_dir      .bz2) 
        extracted_dir=$(basename $extracted_dir      .tar) 

  #
  #  Extract the file, if necessary
  #
  if [ ! -d steps/$extracted_dir ]; then
    tar xf downloads/$download_file_name -C steps
  else
    echo directory steps/$extracted_dir already exists
  fi


  pushd steps/$extracted_dir > /dev/null

  ./configure $XORG_CONFIG
  make install

  popd              > /dev/null

  touch done/$name
}

xls_x_step  util-macros    ftp://ftp.x.org/pub/individual/util/util-macros-1.19.1.tar.bz2

