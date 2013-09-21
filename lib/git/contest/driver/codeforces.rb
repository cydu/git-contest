require 'git/contest/common'
require 'mechanize'
require 'nokogiri'
require 'trollop'

module Git
  module Contest
    module Driver
      class Codeforces < DriverEvent
        def get_opts
          opts = Trollop::options do
            opt(
              :contest_id,
              "Contest ID (Ex: 100, 234, etc...)",
              :type => :string,
              :required => true,
            )
            opt(
              :problem_id,
              "Problem ID (Ex: A, B, etc...)",
              :type => :string,
              :required => true,
            )
          end
          return opts
        end

        def get_desc
          "Codeforces (URL: http://codeforces.com/)"
        end

        def submit(config, source_path, options)
          contest_id = options[:contest_id]
          problem_id = options[:problem_id]

          @client = Mechanize.new {|agent|
            agent.user_agent_alias = 'Windows IE 7'
          }

          login_page = @client.get 'http://codeforces.com/enter'
          login_page.form_with(:action => '') do |form|
            form.handle = config["user"]
            form.password = config["password"]
          end.submit

          custom_test = @client.get "http://codeforces.com/contest/#{contest_id}/submit"
          res_page = custom_test.form_with(:class => 'submit-form') do |form|
            form.submittedProblemIndex = problem_id
            form.programTypeId = "8"
            form.source = File.read(source_path)
          end.submit

          # need to get the newest waiting submissionId
          submission_id = get_submission_id(res_page.body)
          puts "submission_id = #{submission_id}"

          # wait result
          status = get_status_wait(contest_id, submission_id)
          puts "status = #{status}"

          return status
        end

        def get_status_wait(contest_id, submission_id)
          # wait result
          5.times do
            sleep 3
            my_page = @client.get "http://codeforces.com/contest/#{contest_id}/my"
            status = get_status(submission_id, my_page.body)
            return status unless is_waiting(submission_id, my_page.body)
          end
          throw Error "Wait Result Timeout (Codeforces)"
        end
        private :get_status_wait

        def is_waiting(submission_id, body)
          doc = Nokogiri::HTML(body)
          element = doc.xpath('//td[@submissionid="' + submission_id + '"]')[0]
          element["waiting"] == "true"
        end
        private :is_waiting

        def get_status(submission_id, body)
          doc = Nokogiri::HTML(body)
          element = doc.xpath('//td[@submissionid="' + submission_id + '"]')[0]
          element.text().strip
        end
        private :get_status

        def get_submission_id(body)
          doc = Nokogiri::HTML(body)
          elements = doc.xpath('//td[contains(concat(" ",@class," "), " status-cell ")][@waiting="true"]')
          elements[0].attributes()["submissionid"].value.strip
        end
        private :get_submission_id
      end
    end
  end
end
