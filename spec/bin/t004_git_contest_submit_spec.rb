require "spec_helper"

describe "T004: git-contest-submit command" do
  before(:each) do
    init_env
    ENV['GIT_CONTEST_HOME'] = get_path('/mock/default_config')
    ENV['GIT_CONTEST_CONFIG'] = get_path('/mock/t004/config.yml')
    @test_dir = "#{ENV['GIT_CONTEST_TEMP_DIR']}/t004"
    Dir.mkdir @test_dir
    Dir.chdir @test_dir
  end

  after(:each) do
    Dir.chdir @test_dir
    Dir.chdir '..'
    FileUtils.remove_dir @test_dir, :force => true
  end

  context "A001: --version" do
    it "git-contest-submit --version" do
      ret = `#{bin_path("git-contest-submit")} --version`
      ret.should match /git-contest [0-9]+\.[0-9]+\.[0-9]+/
    end

    it "git-contest submit --version" do
      ret = `#{bin_path("git-contest submit")} --version`
      ret.should match /git-contest [0-9]+\.[0-9]+\.[0-9]+/
    end

    it "git contest submit --version" do
      ret = `git contest submit --version`
      ret.should match /git-contest [0-9]+\.[0-9]+\.[0-9]+/
    end
  end

  context "A002: --help" do
    before do
      Dir.mkdir '002'
      Dir.chdir '002'
      Dir.mkdir 'working'
      Dir.chdir 'working'
      File.open 'main.cpp', 'w' do |file|
        file.write 'ac-code'
      end
    end

    context "B001: dummy driver available only test-mode" do
      it "git-contest-submit --help" do
        ret = `#{bin_path('git-contest-submit')} --help`
        ret.should include 'test_dummy'
        ret.should include 'test_11111'
        ret.should include 'test_22222'
        ret.should include 'test_33333'
      end
    end
  end

  context "A003: after init git repo" do
    before do
      Dir.mkdir '003'
      Dir.chdir '003'
      Dir.mkdir 'working'
      Dir.chdir 'working'
      File.open 'main.cpp', 'w' do |file|
        file.write 'ac-code'
      end
    end

    before do
      `#{bin_path("git-contest")} init --defaults`
    end

    it "git-contest-submit test_dummy -c 100 -p A" do
      ret_submit = `#{bin_path("git-contest-submit")} test_dummy -c 100 -p A 2>&1`
      ret_submit.should include '99999'
      ret_submit.should include 'Accepted'
      ret_git = `git log --oneline --decorate --graph`
      ret_git.should include "Dummy 100A: Accepted"
    end
  end

  context "A004: with commit message" do
    before do
      Dir.mkdir '004'
      Dir.chdir '004'
      File.open 'main.cpp', 'w' do |file|
        file.write 'ac-code'
      end
    end

    before do
      bin_exec "init --defaults"
    end

    it "git contest submit test_dummy -c 100 -p A -m '...'" do
      bin_exec "submit test_dummy -c 100 -p A -m 'this is commit message'"
      ret = git_do "log --oneline"
      ret.should include "this is commit message"
    end
  end

  context 'A005: normal submit' do
    before do
      Dir.mkdir '005'
      Dir.chdir '005'
      File.open 'main.cpp', 'w' do |file|
        file.write 'ac-code'
      end
    end

    it "git-contest-submit test_dummy" do
      ret = `#{bin_path('git-contest-submit')} test_dummy 2>&1`
      ret.should include 'Error'
    end

    it "git-contest-submit test_dummy -c 100" do
      ret = `#{bin_path('git-contest-submit')} test_dummy -c 100 2>&1`
      ret.should include 'Error'
    end

    it "git-contest-submit test_dummy -c 100 -p A" do
      ret = `#{bin_path('git-contest-submit')} test_dummy -c 100 -p A 2>&1`
      ret.should include '99999'
      ret.should include 'Accepted'
    end
  end

  context 'A006: --source' do
    before do
      Dir.mkdir '006'
      Dir.chdir '006'
    end

    context "B001: submit single file" do
      before do
        File.open 'ac.cpp', 'w' do |file|
          file.write 'ac-code'
        end
        File.open 'wa.cpp', 'w' do |file|
          file.write 'wa-code'
        end
      end

      it "git contest submit test_dummy -c 100 -p A --source ac.cpp" do
        ret = bin_exec "submit test_dummy -c 100 -p A --source ac.cpp"
        ret.should include '99999'
        ret.should include 'Accepted'
      end

      it "git contest submit test_dummy -c 100 -p A -s ac.cpp" do
        ret = bin_exec "submit test_dummy -c 100 -p A -s ac.cpp"
        ret.should include '99999'
        ret.should include 'Accepted'
      end

      it "git contest submit test_dummy -c 100 -p A --source wa.cpp" do
        ret = bin_exec "submit test_dummy -c 100 -p A --source wa.cpp"
        ret.should include '99999'
        ret.should include 'Wrong Answer'
      end

      it "git contest submit test_dummy -c 100 -p A -s wa.cpp" do
        ret = bin_exec "submit test_dummy -c 100 -p A -s wa.cpp"
        ret.should include '99999'
        ret.should include 'Wrong Answer'
      end
    end

    context "B002: submit multiple files" do
      before do
        File.open '1.cpp', 'w' do |file|
          file.write 'not-ac-code'
        end
        File.open '2.cpp', 'w' do |file|
          file.write 'ac-code'
        end
      end

      it "git contest submit test_dummy -c 100 -p A --source 1.cpp,2.cpp" do
        ret = bin_exec "submit test_dummy -c 100 -p A --source 1.cpp,2.cpp"
        ret.should include '99999'
        ret.should include 'Wrong Answer'
      end

      it "git contest submit test_dummy -c 100 -p A --source 2.cpp,1.cpp" do
        ret = bin_exec "submit test_dummy -c 100 -p A --source 2.cpp,1.cpp"
        ret.should include '99999'
        ret.should include 'Accepted'
      end

      it "git contest submit test_dummy -c 100 -p A -s 1.cpp,2.cpp" do
        ret = bin_exec "submit test_dummy -c 100 -p A -s 1.cpp,2.cpp"
        ret.should include '99999'
        ret.should include 'Wrong Answer'
      end

      it "git contest submit test_dummy -c 100 -p A -s 2.cpp,1.cpp" do
        ret = bin_exec "submit test_dummy -c 100 -p A -s 2.cpp,1.cpp"
        ret.should include '99999'
        ret.should include 'Accepted'
      end
    end
  end
end

