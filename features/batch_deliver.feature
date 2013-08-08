Feature: The batch_deliver binary

  In order to deliver batch reports
  A user should be able to run batch_deliver.

  Background:
    Given BATCH_HOME is "spec/live/uaf-stg"
    And the live directory is cleansed

  Scenario Outline: deliver batch files for specific targets
    When I run the command "bin/batch_deliver <JobStream> <Target> --test"
    Then the command should return successfully
    And  I should not see anything on stderr
    And  a report should be fake delivered to "katt-automation@list.arizona.edu"

    Examples:
      | JobStream | Target |
      | archibus  | all    |
      | archibus  | foo    |

  Scenario Outline: deliver batch files using the file glob fileset file filter class
    When I run the command "bin/batch_deliver <JobStream> <Target> --test"
    Then the command should return successfully
    And  I should not see anything on stderr
    And  a report should be fake delivered to "katt-automation@list.arizona.edu"

    Examples:
      | JobStream       | Target |
      | globteststream  | all    |
      | globteststream  | foo    |