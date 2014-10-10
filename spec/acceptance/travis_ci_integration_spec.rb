require "spec_helper"
require "active_support/core_ext/kernel/reporting"

describe "Travis CI integration" do
  before do
    build_appraisal_file <<-Appraisals.strip_heredoc
      appraise "1.0.0" do
        gem "dummy", "1.0.0"
      end

      appraise "1.1.0" do
        gem "dummy", "1.1.0"
      end
    Appraisals
  end

  context "when user runs `appraisal generate --travis`" do
    it "displays a correct Gemfile directive" do
      output = run("appraisal generate --travis")

      expect(output).to include <<-stdout.strip_heredoc
        # Put this in your .travis.yml
        gemfiles:
          - gemfiles/1.0.0.gemfile
          - gemfiles/1.1.0.gemfile
      stdout
    end
  end

  context "When user has .travis.yml" do
    context "with no gemfiles directive" do
      before do
        write_file ".travis.yml", ""
      end

      it "displays a warning message when run `appraisal generate`" do
        warning = run "appraisal generate 2>&1"

        expect(warning).to include(
          "Note: Run with --travis to generate Travis CI configuration"
        )
      end
    end

    context "with incorrect gemfiles directive" do
      before do
        write_file ".travis.yml", <<-travis_yml
          gemfiles:
            - gemfiles/1.0.0.gemfile
            - gemfiles/1.0.1.gemfile
        travis_yml
      end

      it "displays a warning message when run `appraisal generate`" do
        warning = run "appraisal generate 2>&1"

        expect(warning).to include(
          "Warning: Your gemfiles directive in .travis.yml is incorrect. Run " +
            "`appraisal generate --travis` to get the correct configuration."
        )
      end
    end

    context "with correct gemfiles directive" do
      before do
        write_file ".travis.yml", <<-travis_yml
          gemfiles:
            - gemfiles/1.0.0.gemfile
            - gemfiles/1.1.0.gemfile
        travis_yml
      end

      it "does not display any warning when run `appraisal generate`" do
        warning = run "appraisal generate 2>&1"

        expect(warning).to eq ""
      end
    end
  end

  context "when user does not have .travis.yml" do
    it "does not display any warning when run `appraisal generate`" do
      warning = run "appraisal generate 2>&1"

      expect(warning).to eq ""
    end
  end
end
