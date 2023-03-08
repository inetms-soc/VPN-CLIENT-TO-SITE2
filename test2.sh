detect_os() {
  if [ -e /etc/lsb-release ]; then
    # Ubuntu
    VERSION=$(cat /etc/lsb-release | grep "DISTRIB_RELEASE" | cut -d "=" -f 2)
    echo "This host is running on OS: Ubuntu Version: $VERSION"

  elif [ -e /etc/redhat-release ]; then
    # CentOS
    VERSION=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+' )
    echo "This host is running on OS: CentOS Version: $VERSION"
  else
    echo "Unknown operating system"
  fi
}



detect_os
