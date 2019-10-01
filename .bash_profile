eval "$(rbenv init -)"
export PATH=$PATH:~/bin/./:./bin
export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH" # GNU Grep
export PATH=$PATH:~/.confluent/bin
export PATH=$PATH:~/go/bin
#export PATH=$PATH:~/Projects/pwm/bible-ref
export PATH=$PATH:~/.pipsi/bin
export PATH=$PATH:~/nav/projects/transform/dags:/nav/projects/transform/bin
export PATH=$PATH:$GOPATH/bin
export GOPATH=$HOME/go
export AIRFLOW_HOME=~/.airflow # https://airflow.apache.org/start.html
export PYTHONPATH=~/Projects/nav/bi/transform/dags:/Users/mthorley/Projects/nav/bi/transform/dags/lib
export PYTHONSTARTUP=~/.pythonstartup
export NVM_DIR="$HOME/.nvm"
export BIBLE=ESV
export BIBLES=~/.bibles

export CDPATH=.:..:/nav/projects:$HOME:go/src/git.nav.com/backend/

source ~/.bash/prompt
source ~/.git-completion.bash

if [ -f $(brew --prefix)/etc/bash_completion ]; then
. $(brew --prefix)/etc/bash_completion
fi

#function mycd() {
#  cd "$@"
#  if [ -f ./.bashrc ]; then source ./.bashrc; fi
#}
#alias cd=mycd
alias ".."="cd .."
alias "..."="cd ../.."
alias "cd.."="cd .."
alias cdbi="cd ~/Projects/nav/bi/transform"
alias cdex="cd ~/Projects/nav/bi/extract"

alias rcshell="vi ~/.bash_profile && source ~/.bash_profile"
alias rcgit="vi ~/.gitconfig"
alias rcvim="vi ~/.vimrc"
alias rcreload="source ~/.bash_profile"

alias chmox="chmod +x "
alias grep="grep -E --color"
alias igrep="grep -i"
alias ref=bible-ref
alias lpr="lpr -o cpi=16 -o lpi=8 -o page-left=16 -o page-right=16 -o page-top=16 -o page-bottom=16  -o sides=one-sided -o prettyprint"
alias g=git
alias rs=redshift-sql


mk() {
  if find . -name Makefile |grep '.*' 1>&2>/dev/null; then
    make $@
  else
    bash -c '_mkrecur() {
      cd ..
      if find . -name Makefile |grep ".*" 1>&2>/dev/null; then
        echo Using $(pwd)/Makefile
        make $@
      else
        if [ $(pwd) == "/" ]; then
          echo "Stopping at rootdir."
          exit 1
        else
          _mkrecur
        fi
      fi
    };
    _mkrecur'
  fi
}

fixbrew() {
  # I keep getting this error from homebrew
  sudo chown -R $(whoami) /usr/local/share/man/man8
  chmod u+w /usr/local/share/man/man8
  brew $@
}

show_colour() {
     perl -e 'foreach $a(@ARGV){print "\e[48;2;".join(";",unpack("C*",pack("H*",$a)))."m \e[49m "};print "\n"' "$@"
}

function pbible-ref {
  bible-ref "$@" |grep -v 000 |cut -d: -f2 |cut -d' ' -f2- |sed 's/  / /g' |tr '\n' ' ' |fold -s -w 120
  echo
}

function vim-all {
  if [ $# -eq 0 ]; then
    vim -o "$@"
  else
    xargs -o  vim -o
  fi
}

function f {
  local name="$1"
  local path="$2"
  if [ "x${path}" == "x" ]; then
    path="./"
  fi
  find ${path} -name ${name}
}

function find-by-ext {
  local ext="$1"
  local path="$2"
  if [ "x{path}" == "x" ];then
    path="./"
  fi
  find ${path} -name '*.'${ext}
}

function x {
  if [ $# -eq 1 ]; then
    grep --color=always -EiI $1 .
  else
    grep --color=always -EiI $@
  fi
}

function xr {
  if [ $# -eq 1 ]; then
    grep --color=always -ERiI $1 .
  else
    grep --color=always -ERiI $@
  fi
}

alias xs="grep --color=always -EI"
alias xrs="grep --color=always -ERI"
alias xv="grep --color=always -EviI"

psx() {
  ps aux|grep $@
}


# https://superuser.com/questions/419775/with-bash-iterm2-how-to-name-tabs
function title {
    echo -ne "\033]0;"$*"\007"
}

function _cp() {
  cp -r "$1" _"$1"
}

function _mv() {
  arg="$1"
  char=${arg:0:1}
  if [ "x$char" != "x_" ]; then
    echo "Error: $1 does not begin with leading underscore." >&2
    return 1
  fi
  mv $arg ${arg:1}
}

function print1 {
  awk '{print $1}'
}

function col1 {
  awk '{print $1}'
}

function col2 {
  awk '{print $2}'
}

function colk3 {
  awk '{print $3}'
}

function awk-tab {
  awk -F $'\t' "$@"
}

function mkcd {
  mkdir dir -p $1
  cd $1
}

alias sha256="shasum -a 256"
function aes-enc {
  local infile="$1"
  local outfile="$infile.aes-encrypted"

  echo Encrypting $infile
  if openssl aes-256-cbc -a -salt -in $infile -out $outfile; then
    echo Success. New encrypted file at $outfile
  else
    echo File not encrypted >&2
    return 1
  fi
}

function aes-dec {
  local infile="$1"
  local outfile=$(mktemp XXXXXXXX)
  local option="$2"

  echo Attempting to decrypt $infile >&2
  if openssl aes-256-cbc -d -a -salt -in $infile -out $outfile; then
    if [ "$option" == "export" ]; then
      export $(grep -v '^#' $outfile | xargs -0)
    else
      cat $outfile
    fi
    rm $outfile
  else
    rm $outfile
    echo File not decrypted >&2
    return 1
  fi
}

alias dec-profile="aes-dec ~/.profile.aes-encrypted export"

function .git-origin {
  if ! git remote -v 1>&2>/dev/null; then return 1; fi
  git remote -v |grep -E '^origin\t' |head -n1 |cut -f2 |cut -d' ' -f1
}

function .repo_name {
  .git-origin |awk -F"/" '{print $NF}' |awk '{print $1}' |sed 's/.git//g'
 }

function .container_name() {
  docker ps |grep $(.repo_name) |awk '{print $NF}'
}

function docker-stop-all {
  docker ps |awk '{ if (NR>1) print $1 }'|xargs docker stop
}

# Git

alias gsmp="git stash ; git checkout master; git pull"
alias gmp="git checkout master; git pull"
alias gb="git branch"
alias gbr="git branches-recent"
alias gm="git checkout master"
alias gmro="git checkout master; git fetch origin master; git reset --hard origin/master"
alias gs="git status"
alias gs.="git status ."
alias gdf="git diff --color"
alias gcb="git checkout -b"
alias gco="git checkout"
alias grh="git reset --hard"
alias gp="git pull"
alias gl="git log"

## Docker

function db() {
  if [ ! -f ./Dockerfile ]; then
    echo "No Dockerfile in cwd." >&2
    return 1
  fi

  local givenName="$1"
  local tagName=$(.repo_name)

  if [ "x${givenName}" != "x" ]; then
    tagName=$givenName
  fi

  echo Building $tagName
  docker build . -t $tagName
}

function dr() {
  local container=$(.repo_name)
  docker run $container
}

## Kubernetes

alias kc=kubectl

function kc-pod-name {
  local pods=$(kubectl get pods |grep $(.repo_name))
  if [ $(echo $pods |wc -l) -gt 1 ]; then
    pods=$(echo $pods |grep Running)
  fi
  echo $pods |awk '{print $1}'
}

function kcbash {
  kubectl exec -it $(kc-pod-name) bash
}

function kclogs {
  kubectl logs $(kc-pod-name)
}

function kctail {
  kubectl logs -f $(kc-pod-name)
}

function kcls {
  kubectl get pods
}

function kcstatus {
  kubectl get pods |grep $(.repo_name)
}

function kcport {
  kubectl port-forward $(kc-pod-name) $@
}

function kcuse {
  if [ -z $1 ]; then
    kubectl config use-context int1
  else
    kubectl config use-context $1
  fi
}

function cilogs {
  gitlab-ci-logs $(.repo_name)
}

function filter-numeric {
  sed 's/[^0-9]//g'
}

function filter-alpha {
  sed 's/[^a-zA-Z]//g'
}

function filter-alphanums {
  sed 's/[^a-zA-Z0-9]//g'
}

function downcase {
  tr '[:upper:]' '[:lower:]'
}

function upcase {
  tr '[:lower:]' '[:upper:]'
}

function trim {
  awk '{$1=$1};1'
}

function replace {
  sed "s/$1/$2/g"
}

function join-on-pipe {
  sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\|/g'
}

function remove-trailing-whitespace {
  sed -i '' 's/[[:space:]]\{1,\}$//' "$1"
}

function comma {
  sed 's/$/,/g'
}


function gitnewup {
  # usage: gitnewup Add something to Project for purpose
  git stash && git checkout master && git pull && git stash pop
  local message="$@"
  local branch=$(echo $message |sed 's/ /-/g' |tr '[:upper:]' '[:lower:]')
  git checkout -b $branch
  git commit -am "$message"

  push=$(git push --set-upstream origin $branch 2>&1)
  url=$(echo "$push" |grep -o 'https://git.nav.com/.*/merge_requests/.*')
  echo "$push"
  echo url: "$url"
  echo url: $url
  open $url

  # url="unset"
  # while read line; do
  #   _url=$(echo $line |grep -o 'https://git.nav.com/.*/merge_requests/')
  #   if [ ${_url} != "" ];then
  #     echo url: $_url
  #     url=$_url
  #   fi
  #   echo line: "$line"
  # done < <(git push --set-upstream origin $branch)
  # echo last url: $url
  # if [ "$url" != "" ]; then open "$url"; fi
}


function _gitlab_get(){
  curl -s --header "Private-Token: $GITLAB_TOKEN" $@
}

function gitlab_projects {
  _gitlab_get https://git.nav.com/api/v4/projects
 }

function gitlab-this-project.json {
  gitlab_projects |jq '.[]| select(.ssh_url_to_repo=="'"$(.git-origin)"'")'
}

function ,gitlab-open-web {
  open $(gitlab-this-project.json |jq '.web_url' |sed 's/"//g')
}

function ,gitlab-open-pipelines {
  open $(gitlab-this-project.json |jq '.web_url' |sed 's/"//g')/pipelines
}

# Thoughts on style
# begin internal/private methods with _
# being functions as commands with ,

my-jira() {
  echo "Assigned"
  jira list --template table --query "resolution = unresolved and assignee=currentuser() ORDER BY created"
  echo "Created"
  jira list --template table --query "resolution = unresolved and creator=currentuser() ORDER BY created"
}

function bi_find_pii_words {
  grep -RiE --color '(email|address|first_name|last_name|phone|geo)' $@
}

function bi_find_pii_columns {
  grep -RiE --color '\.(email|address|first_name|last_name|phone|geo)' $@
}

eval "$(pyenv init -)"
#pyenv global 3.4.3

xargs0() {
  tr \\n \\0 |xargs -n1 -0 $@
}

xargs0item() {
  tr \\n \\0 |xargs -n1 -0 -I ITEM $@
}

from-join() {
  grep -Eio "(from|join) \w+(\.\w+)?" "$@" |cut -c6- |sort -u
}

pie() {
  perl -p -i -e "s/$1/$2/g" *
}

count-occurs-per-line() {
  char="$1"
  file="$2"
  grep -n -o "$char" "$file" | sort -n | uniq -c | cut -d : -f 1
}

double-space() {
  sed '/^$/d' "$1" | sed G
}
# xargs example: $ find ... |tr \\n \\0 |xargs -n1 -0 -I file ...
# perl print on capture $ perl -ne '/<relation.*?>(.*?)<\/relation>/ && print "$1\n";' sample.twb # https://www.commandlinefu.com/commands/view/13429/print-only-matched-pattern
# https://www.regular-expressions.info/replacebackref.html
# perl replace between two strings $ perl -p -e "s/(<relation.*?type='text'>)(.*?)(<\/relation>)/\1FOOBAR\3/g" sample.twb
# https://stackoverflow.com/questions/6994947/how-to-replace-a-string-in-an-existing-file-in-perl
# perl inplace replace with bak file $ perl -pi.bak -e 's/blue/red/g'
