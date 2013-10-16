require 'git/contest/version'
require 'git/contest/test'
require 'git/contest/git'
require 'git/contest/driver/codeforces'
require 'git/contest/driver/aizu_online_judge'
require 'git/contest/driver/uva_online_judge'
require 'git/contest/driver/dummy' if is_test_mode?
require 'yaml'

GIT_CONTEST_HOME_DEFAULT = File.expand_path('~/.git-contest')
GIT_CONTEST_CONFIG_DEFAULT = GIT_CONTEST_HOME_DEFAULT + '/config.yml'

def init
  init_global
  init_home
end

def init_global
  $GIT_CONTEST_HOME   = File.expand_path(ENV['GIT_CONTEST_HOME'] || GIT_CONTEST_HOME_DEFAULT)
  $GIT_CONTEST_CONFIG = File.expand_path(ENV['GIT_CONTEST_CONFIG'] || GIT_CONTEST_CONFIG_DEFAULT)
  $MASTER = git_do 'config --get git.contest.branch.master'
  $PREFIX = git_do 'config --get git.contest.branch.prefix'
end

def init_home
  if ! FileTest.directory? $GIT_CONTEST_HOME
    FileUtils.mkdir $GIT_CONTEST_HOME
  end
  if ! FileTest.exists? $GIT_CONTEST_CONFIG
    FileUtils.touch $GIT_CONTEST_CONFIG
  end
end

def get_config
  config_path = File.expand_path($GIT_CONTEST_CONFIG)
  YAML.load_file config_path
end

