#
#      TODO: The book suggests to store these variabls
#            in /etc/profile.d/xorg.sh
#
export XORG_PREFIX=/usr
export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static"

export lfs_download_dir=/etc/lfs/downloads

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


lfs_download() {
  local download_url=$1

  local download_file_name=$(basename $download_url)

  #
  #  Download the file, if necessary
  #
  if [ ! -f $lfs_download_dir/$download_file_name ]; then
    echo downloading $download_file_name
    wget $download_url -P $lfs_download_dir
  else
    echo $download_file_name already downloaded
  fi
}

lfs_download_and_extract() {
  local download_url=$1
  local dest_dir=$2

  if [ ! -d "$dest_dir" ]; then
    echo "lfs_download_and_extract: $dest_dir does not exist"
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
    echo "trying to untar $lfs_download_dir/$ into $dest_dir, PWD=$PWD"
    tar xf $lfs_download_dir/$download_file_name -C $dest_dir
  else
    echo directory $dest_dir/$extracted_dir already exists
  fi

}

lfs_x_step() {

  trap 'echo Error at line $LINENO; exit 1' ERR

  local name=$1

  if [ -e done/$name ]; then
    echo "$name already done"
    return 0
  fi


  pushd steps/$name > /dev/null

  . go

  popd              > /dev/null

  touch done/$name
}

lfs_x_step  util-macros
lfs_x_step  protocol-headers

