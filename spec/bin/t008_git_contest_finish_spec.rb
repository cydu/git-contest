require "spec_helper"

# Do not forget --no-edit option

describe "T008: git-contest-finish" do

  before(:each) do
    init_env
    @test_dir = "#{ENV['GIT_CONTEST_TEMP_DIR']}/t008"
    Dir.mkdir @test_dir
    Dir.chdir @test_dir
    # debug_on
  end

  after(:each) do
    Dir.chdir '..'
    FileUtils.remove_dir @test_dir, :force => true
  end

  describe "001: --keep" do

    before do
      Dir.mkdir "001"
      Dir.chdir "001"
    end

    after do
      Dir.chdir ".."
    end

    it "001: init -> start -> empty-commits -> finish" do
      bin_exec "init --defaults"
      bin_exec "start branch1"
      git_do "commit --allow-empty -m 'this is commit'"
      bin_exec "finish --no-edit"
      ret1 = git_do "branch"
      ret_log1 = git_do "log --oneline master"
      ret1.include?("branch1").should === false
      ret_log1.include?("this is commit").should === true
    end

    it "002: init -> start -> empty-commits -> finish --keep" do
      bin_exec "init --defaults"
      bin_exec "start branch1"
      git_do "commit --allow-empty -m 'this is commit'"
      bin_exec "finish --no-edit --keep"
      ret1 = git_do "branch"
      ret_log1 = git_do "log --oneline master"
      ret1.include?("branch1").should === true
      ret_log1.include?("this is commit").should === true
    end

    it "003: init -> start -> empty-commits -> finish -k" do
      bin_exec "init --defaults"
      bin_exec "start branch1"
      git_do "commit --allow-empty -m 'this is commit'"
      bin_exec "finish --no-edit -k"
      ret1 = git_do "branch"
      ret_log1 = git_do "log --oneline master"
      ret1.include?("branch1").should === true
      ret_log1.include?("this is commit").should === true
    end

  end

  describe "002: --rebase" do

    before do
      Dir.mkdir "002"
      Dir.chdir "002"
    end

    after do
      Dir.chdir ".."
    end

    it "001: init -> start -> empty-commits -> finish --rebase" do
      # create branches: branch1(normal) -> branch2(rebase) -> branch3(normal)
      bin_exec "init --defaults"
      bin_exec "start branch1"
      10.times {|x|
        name = "test-1.#{x}"
        FileUtils.touch name
        git_do "add #{name}"
        git_do "commit -m 'Add #{name}'"
      }
      bin_exec "start branch2"
      10.times {|x|
        name = "test-2.#{x}"
        FileUtils.touch name
        git_do "add #{name}"
        git_do "commit -m 'Add #{name}'"
      }
      bin_exec "start branch3"
      10.times {|x|
        name = "test-3.#{x}"
        FileUtils.touch name
        git_do "add #{name}"
        git_do "commit -m 'Add #{name}'"
      }
      # finish branches
      ret_branch_1 = git_do "branch"
      bin_exec "finish branch1 --no-edit"
      bin_exec "finish branch2 --no-edit --rebase"
      bin_exec "finish branch3 --no-edit"
      ret_branch_2 = git_do "branch"
      ret_log = git_do "log --oneline"
      ret_branch_1.include?("branch1").should === true
      ret_branch_1.include?("branch2").should === true
      ret_branch_1.include?("branch3").should === true
      ret_branch_2.include?("branch1").should === false
      ret_branch_2.include?("branch2").should === false
      ret_branch_2.include?("branch3").should === false
      (!!ret_log.match(/test-2.*test-3.*test-1/m)).should === true
    end

  end

  describe "003: --force-delete" do

    before do
      Dir.mkdir "003"
      Dir.chdir "003"
    end

    after do
      Dir.chdir ".."
    end

    # TODO: recheck
    it "001: init -> start -> trigger merge error -> finish --force-delete" do
      # make conflict
      bin_exec "init --defaults"
      FileUtils.touch "test.txt"
      git_do "add test.txt"
      git_do "commit -m 'Add test.txt'"
      bin_exec "start branch1"
      bin_exec "start branch2"
      git_do "checkout contest/branch1"
      File.open "test.txt", "w" do |file|
        file.write "test1"
      end
      # git_do "add test.txt"
      # git_do "commit -m 'Edit test.txt @ branch1'"
      git_do "checkout contest/branch2"
      File.open "test.txt", "w" do |file|
        file.write "test2"
      end
      git_do "add test.txt"
      git_do "commit -m 'Edit test.txt @ branch2'"
      # finish
      bin_exec "finish branch1 --no-edit"
      bin_exec "finish branch2 --force-delete --no-edit"
      ret_branch = git_do "branch"
      ret_branch.include?("contest/branch1").should === false
      ret_branch.include?("contest/branch2").should === false
    end

  end

  describe "004: --squash" do

    before do
      Dir.mkdir "004"
      Dir.chdir "004"
    end

    after do
      Dir.chdir ".."
    end

    it "001: init -> start -> empty-commits -> finish --squash" do
      bin_exec "init --defaults"
      bin_exec "start branch1"
      10.times {|x|
        filename = "test#{x}.txt"
        FileUtils.touch filename
        git_do "add #{filename}"
        git_do "commit -m 'this is commit #{x}'"
      }
      bin_exec "finish --no-edit --squash branch1"
      ret_log1 = git_do "log --oneline"
      ret_branch1 = git_do "branch"
      ret_branch1.include?("branch1").should === false
      ret_log1.include?("this is commit").should === true
      ret_log1.include?("Squashed commit").should === true
    end

  end

  describe "005: --fetch" do

    before do
      Dir.mkdir "005"
      Dir.chdir "005"
      Dir.mkdir "src"
      Dir.chdir "src"
      bin_exec "init --defaults"
      bin_exec "start branch1"
      10.times {|x| git_do "commit --allow-empty -m 'this is commit #{x}'" }
      Dir.chdir ".."
      git_do "clone src dest"

      Dir.chdir "dest"
    end

    after do
      Dir.chdir ".."
      Dir.chdir ".."
    end

    it "001: init -> start -> clone -> checkout@dest -> empty-commits@dest -> finish@dest" do
      git_do "checkout -b master origin/master"
      bin_exec "init --defaults"
      bin_exec "start --fetch branch1"
      bin_exec "finish --fetch branch1 --no-edit"
      ret_branch2 = git_do "branch"
      Dir.chdir ".."
      Dir.chdir "src"
      ret_branch1 = git_do "branch"
      git_do "checkout master"
      ret_branch1.include?('branch1').should === true
      ret_branch2.include?('branch1').should === false
    end

  end

end

