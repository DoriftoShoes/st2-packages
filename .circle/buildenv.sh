#!/bin/bash
set -e

distros=($DISTROS)
DISTRO=${distros[$CIRCLE_NODE_INDEX]}

fetch_version() {
  if [ -f ../st2common/st2common/__init__.py ]; then
    # Get st2 version based on hardcoded string in st2common
    # build takes place in `st2` repo
    python -c 'execfile("../st2common/st2common/__init__.py"); print __version__'
  else
    # build takes place in `st2-packages` repo
    curl -sSL -o /tmp/st2_version.py ${ST2_GITURL}/raw/${ST2_GITREV}/st2common/st2common/__init__.py
    python -c 'execfile("/tmp/st2_version.py"); print __version__'
  fi
}

# Needs explantion???
st2_giturl() {
  # Handle pull requests properly
  if [ -z "$CIRCLE_PR_REPONAME" ]; then
    echo "https://github.com/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}"
  else
    echo "https://github.com/${CIRCLE_PR_USERNAME}/${CIRCLE_PR_REPONAME}"
  fi
}

# Write export lines into ~/.buildenv and also source it in ~/.circlerc
write_env() {
  for e in $*; do
    eval "value=\$$e"
    [ -z "$value" ] || echo "export $e=$value" >> ~/.buildenv
  done
  echo ". ~/.buildenv" >> ~/.circlerc
}

# ---
# ST2_GITURL - st2 GitHub repository (ex: https://github.com/StackStorm/st2)
# ST2_GITREV - st2 branch name (ex: master, v1.2.1). This will be used to determine correct Docker Tag: `latest`, `1.2.1`
# ST2PKG_VERSION - st2 version, will be reused in Docker image metadata (ex: 1.2dev)
# ST2PKG_RELEASE - Release number aka revision number for `st2bundle` package, will be reused in Docker metadata (ex: 4)

ST2_GITURL=${ST2_GITURL:-$(st2_giturl)}
ST2_GITREV=${ST2_GITREV:-$CIRCLE_BRANCH}
ST2PKG_VERSION=$(fetch_version)
ST2PKG_RELEASE=$(.circle/bintray.sh next-revision ${DISTRO}_staging ${ST2PKG_VERSION})

re="\\b$DISTRO\\b"
[[ "$NOTESTS" =~ $re ]] && TESTING=0

write_env ST2_GITURL ST2_GITREV ST2PKG_VERSION ST2PKG_RELEASE DISTRO TESTING

cat ~/.buildenv
