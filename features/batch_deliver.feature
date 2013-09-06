Feature: The batch_deliver binary

  In order to deliver batch reports
  A user should be able to run batch_deliver.

  Background:
    Given BATCH_HOME is "spec/live/uaf-stg"
    And the live directory is cleansed

  Scenario Outline: Deliver a batch report to a single output
    When I run the command "bin/batch_deliver <JobStream> <Target> --test"
    Then the command should return successfully
      And  I should not see anything on stderr
      And  a report should be fake delivered to "katt-automation@list.arizona.edu"

    Examples:
      | JobStream | Target    |
      | foo       | job_start |

  Scenario Outline: Deliver a batch report to multiple outputs
    When I run the command "bin/batch_deliver <JobStream> <Target> --test"
    Then the command should return successfully
      And  I should not see anything on stderr
      And  a report should be fake delivered to "katt-automation@list.arizona.edu"

    Examples:
      | JobStream | Target     |
      | foo       | job_start  |      
      | foo       | job_ok     |      
      | foo       | job_not_ok |

  Scenario Outline: Deliver a batch report to all outputs
    When I run the command "bin/batch_deliver <JobStream> <Target> --test"
    Then the command should return successfully
      And  I should not see anything on stderr
      And  a report should be fake delivered to "katt-automation@list.arizona.edu"

    Examples:
      | JobStream | Target     |
      | archibus  | all        |

  Scenario Outline: Deliver a batch report with attachments using the glob attachment filter classes
    When I run the command "bin/batch_deliver <JobStream> <Target> --test"
    Then the command should return successfully
      And  I should not see anything on stderr
      And  a report should be fake delivered to "katt-automation@list.arizona.edu"

    Examples:
      | JobStream | Target     |
      | einvoice  | job_not_ok |      
      | einvoice  | job_ok     |