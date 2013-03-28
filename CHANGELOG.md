# CHANGE LOG
## v0.1.5 (alpha) - 2013-03-27
This release took over a month and has a lot of updates, we switched to require.js for our JavaScript stuff, granted that's still not where it should be but we'll get there. Now to the fun part - what has changed:
* Switch to Require.js
* Strategy pattern for provider (yes we'll have multiple providers in the future)
* Changed the export view so interactions are now paired with cases
* We fixed a bugs

## v0.1.4 (alpha) - 2013-02-08
* Issue #19: Fixed the weird calendar bug by updating the calendar source.
* Issue #21: Fixed the export overview bug.
* Issue #22: Switched from sprockets css combine to SASS import

## v0.1.3 (alpha) - 2013-02-05
* Issue #18: The bug with date filter has been fixed.
* Issue #20: CSV is now default export.
* Issue #3: Every export has now a 3 step indicator (Queue|Exporting|Finished) that'll update automatically from step to step. The export info also shows the filter settings now.

## v0.1.2-encryption (hotfix) - 2013-02-03
* Added attr_encryptor to safely encrypt the secret column.

## v0.1.2 (alpha) - 2013-01-31
This release is plain a security overhaul.

* Issue #5: Exports are now separated by the environment.
* Issue #11: Downloads are now private which means the urls are expiring after 5 minutes.
* Issue #12: We used http://guides.rubyonrails.org/security.html to check the app for security vulnerabilities.
* Issue #13: Added Google Analytics for the production environment.
* Issue #14: Changed Procfile to use RAILS_ENV as environment.

## v0.1.1 (alpha) - 2013-01-30
Some bugs have been fixed and the codebase is now 100% covered with tests. 

* Issue #1: The csv export showed two lines for each record in Excel.
* Issue #2: The csv export didn't know how to handle ruby hashes.
* Issue #6: Deleting the current authorization threw an error.
* Issue #8: Writing tests for the codebase: `All Files (100.0% covered at 26.96 hits/line)`
* Issue #10: Added NewRelic to monitor the app

## v0.1.0 (alpha) - 2013-01-28
The first version to be on [Heroku](http://www.heroku.com). This version supports export of cases, customers and interactions, it allows you to search and filter your exports and export in multiple formats:

* JSON
* XML
* CSV
