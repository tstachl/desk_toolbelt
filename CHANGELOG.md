# CHANGE LOG
## v0.1.2-encryption (hotfix) - 2012-02-03
* Added attr_encryptor to safely encrypt the secret column.

## v0.1.2 (alpha) - 2012-01-31
This release is plain a security overhaul.

* Issue #5: Exports are now separated by the environment.
* Issue #11: Downloads are now private which means the urls are expiring after 5 minutes.
* Issue #12: We used http://guides.rubyonrails.org/security.html to check the app for security vulnerabilities.
* Issue #13: Added Google Analytics for the production environment.
* Issue #14: Changed Procfile to use RAILS_ENV as environment.

## v0.1.1 (alpha) - 2012-01-30
Some bugs have been fixed and the codebase is now 100% covered with tests. 

* Issue #1: The csv export showed two lines for each record in Excel.
* Issue #2: The csv export didn't know how to handle ruby hashes.
* Issue #6: Deleting the current authorization threw an error.
* Issue #8: Writing tests for the codebase: `All Files (100.0% covered at 26.96 hits/line)`
* Issue #10: Added NewRelic to monitor the app

## v0.1.0 (alpha) - 2012-01-28
The first version to be on [Heroku](http://www.heroku.com). This version supports export of cases, customers and interactions, it allows you to search and filter your exports and export in multiple formats:

* JSON
* XML
* CSV