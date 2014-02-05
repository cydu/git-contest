require "spec_helper"

# Don't forget --defaults option

describe "T009: git-contest-init" do
  context "A001: --force" do
    it "001: init -> init" do
      ret1 = bin_exec "init --defaults"
      ret_config1 = git_do("config --get git.contest.branch.master")
      ret2 = bin_exec "init --defaults"
      ret_config1.should                                           === "master"
      ret1.include?("Error: unknown argument").should              === false
      ret2.include?("Error: unknown argument").should              === false
      ret1.include?("Already initialized for git-contest.").should === false
      ret1.include?("use: git contest init -f").should             === false
      ret2.include?("Already initialized for git-contest.").should === true
      ret2.include?("use: git contest init -f").should             === true
    end

    it "002: init -> init -f -> init --force" do
      ret1 = bin_exec "init --defaults"
      ret_config1 = git_do("config --get git.contest.branch.master")
      ret2 = bin_exec "init --defaults -f"
      ret3 = bin_exec "init --defaults --force"
      ret_config1.should === "master"
      ret1.include?("Error: unknown argument").should              === false
      ret2.include?("Error: unknown argument").should              === false
      ret3.include?("Error: unknown argument").should              === false
      ret1.include?("Already initialized for git-contest.").should === false
      ret1.include?("use: git contest init -f").should             === false
      ret2.include?("Already initialized for git-contest.").should === false
      ret2.include?("use: git contest init -f").should             === false
      ret3.include?("Already initialized for git-contest.").should === false
      ret3.include?("use: git contest init -f").should             === false
    end

    it "003: init -f -> init -f -> init --force" do
      ret1 = bin_exec "init --defaults -f"
      ret_config1 = git_do("config --get git.contest.branch.master")
      ret2 = bin_exec "init --defaults -f"
      ret3 = bin_exec "init --defaults --force"
      ret_config1.should                                           === "master"
      ret1.include?("Error: unknown argument").should              === false
      ret2.include?("Error: unknown argument").should              === false
      ret3.include?("Error: unknown argument").should              === false
      ret1.include?("Already initialized for git-contest.").should === false
      ret1.include?("use: git contest init -f").should             === false
      ret2.include?("Already initialized for git-contest.").should === false
      ret2.include?("use: git contest init -f").should             === false
      ret3.include?("Already initialized for git-contest.").should === false
      ret3.include?("use: git contest init -f").should             === false
    end
  end
end

