# frozen_string_literal: true

require "spec_helper"
require "support/tasks"

describe "Executing Decidim User tasks" do
  describe "rake decidim:user:destroy_accounts", type: :task do
    let!(:organizations) { create_list(:organization, 2) }
    let(:task_name) { :"decidim:user:destroy_accounts" }
    let(:argument_error_output) { /ArgumentError : Please run task with RAILS_FORCE='true' env variable to ensure your choice/ }

    shared_examples_for "have to rescue error" do |error, output|
      it "have to rescue #{error}" do
        Rake::Task[task_name].reenable
        expect { Rake::Task[task_name].invoke }.to output(output).to_stdout
      end
    end

    context "when executing task" do
      context "without env variable" do
        it_behaves_like"have to rescue error", "ArgumentError", /ArgumentError : Please run task with RAILS_FORCE='true' env variable to ensure your choice/
      end

      context "with env variable" do
        before do
          ENV["RAILS_FORCE"] = "true"
        end

        it "have to be executed without failures" do
          Rake::Task[:"decidim:user:destroy_accounts"].reenable
          expect { Rake::Task[task_name].invoke }.not_to output(argument_error_output).to_stdout
        end

        context "when RAILS_FORCE has not a valid content" do
          before do
            ENV["RAILS_FORCE"] = "abc"
          end

          it_behaves_like "have to rescue error", "ArgumentError", /ArgumentError : Please run task with RAILS_FORCE='true' env variable to ensure your choice/
        end
      end
    end
  end
end
