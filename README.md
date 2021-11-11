iMazing App Fixer
=================

[![Build Status](https://img.shields.io/github/workflow/status/DigiDNA/iMazingAppFixer/ci-mac?label=macOS&logo=apple)](https://github.com/DigiDNA/iMazingAppFixer/actions/workflows/ci-mac.yaml)
[![Issues](http://img.shields.io/github/issues/DigiDNA/iMazingAppFixer.svg?logo=github)](https://github.com/DigiDNA/iMazingAppFixer/issues)
![Status](https://img.shields.io/badge/status-legacy-red.svg?logo=git)
![License](https://img.shields.io/badge/license-mit-brightgreen.svg?logo=open-source-initiative)  
[![Contact](https://img.shields.io/badge/follow-@digidna-blue.svg?logo=twitter&style=social)](https://twitter.com/digidna)

About
-----

A small utility for people having issues starting applications on OS X.
Some applications may be incorrectly flagged as damaged by OS X, or even flagged as legacy PowerPC applications.

The utility lets you select any application and will attempt to repair it.

The repair process will clear all extended attributes on the application bundle by running:

    xattr -c -r /path/to/application.app
    
It will also reset the [LaunchServices] database by running:

    lsregister -kill -r -domain local -domain system -domain user
    
Note that `lsregister` is located in the `LaunchServices` system framework.

License
-------

iMazing App Fixer is released under the terms of the MIT License.

Repository Infos
----------------

    Owner:			DigiDNA
    Web:			imazing.com
    Blog:			imazing.com/blog
    Twitter:		@DigiDNA
    GitHub:			github.com/DigiDNA

[LaunchServices]: https://developer.apple.com/library/prerelease/mac/documentation/Carbon/Conceptual/LaunchServicesConcepts/LSCConcepts/LSCConcepts.html
