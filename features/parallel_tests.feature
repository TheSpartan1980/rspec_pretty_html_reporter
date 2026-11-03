Feature: Parallel Tests

  Example: The overview lists the groups of every worker
    Given a parallel report has been generated
    Then the parallel overview has 7 links to other pages
    And the parallel overview displays the totals "7", "9" and "11"

  Example: Every overview link opens a report of its own
    Given a parallel report has been generated
    Then every link in the parallel overview opens a different report file

  Example: A new run removes the report of an earlier run
    Given a parallel report has been generated
    Then the file "stale.html" is not in the parallel report
