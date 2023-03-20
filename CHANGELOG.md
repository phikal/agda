Release notes for Agda version 2.6.5
====================================

Highlights
----------

Installation
------------

* Agda supports GHC versions 8.6.5 to 9.8.1.

Pragmas and options
-------------------

Syntax
------

Additions to the Agda syntax.

Language
--------

Changes to type checker and other components defining the Agda language.

Reflection
----------

Changes to the meta-programming facilities.

Library management
------------------

Interaction and emacs mode
--------------------------

Backends
--------

Other issues closed
-------------------

For 2.6.5, the following issues were also
[closed](https://github.com/agda/agda/issues?q=is%3Aissue+milestone%3A2.6.5+is%3Aclosed)
(see [bug tracker](https://github.com/agda/agda/issues)):

* Helper function (`C-c C-h`) does not abstract over module parameters anymore
  (see [#2271](https://github.com/agda/agda/issues/2271)).

* _Go-to-definition_ (`M-.`) is now implemented using Emacs' built-in
  [Xref]. Basic usage stays the same (`M-.` or using the mouse), but
  now also includes searching for definitions by exact (`C-u M-.`) or
  approximate names (`C-M-.`) and listing references (`M-?`) in loaded
  files.

[Xref]: https://www.gnu.org/software/emacs/manual/html_node/emacs/Xref.html
