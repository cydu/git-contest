require 'spec_helper'
WebMock.disable_net_connect!

require 'mechanize'
require 'git/contest/driver/aizu_online_judge'

def read_file path
  real_path = File.expand_path(File.dirname(__FILE__) + path)
  File.read real_path
end

describe "T001: Git::Contest::Driver::AizuOnlineJudge" do
  before do
    # setup
    @aoj = Git::Contest::Driver::AizuOnlineJudge.new
    @aoj.stub(:sleep).and_return(0)
    @aoj.client = Mechanize.new {|agent|
      agent.user_agent_alias = 'Windows IE 7'
    }

    # basic status_log
    WebMock.stub_request(
      :get,
      /http:\/\/judge\.u-aizu\.ac\.jp\/onlinejudge\/webservice\/status_log\??.*/
    ).to_return(
      :status => 200,
      :body => read_file('/mock/t001.status_log.xml'),
      :header => {
        'Content-Type' => 'text/xml',
      },
    )
  end

  describe "001: #get_status_wait" do
    it "001: Check Status" do
      ret = @aoj.get_status_wait 'test_user', '111'
      ret.should === "Wrong Answer"
    end
  end

  describe "002: #get_status_wait" do
    before do
      # has 2 statuses
      WebMock.stub_request(
        :get,
        /http:\/\/judge\.u-aizu\.ac\.jp\/onlinejudge\/webservice\/status_log\??.*/
      ).to_return(
        :status => 200,
        :body => read_file('/mock/t001_002.status_log.xml'),
        :header => {
          'Content-Type' => 'text/xml',
        },
      )
    end
    it "001: Check Status" do
      ret = @aoj.get_status_wait 'test_user', '111'
      ret.should === "Wrong Answer"
    end
  end
end

