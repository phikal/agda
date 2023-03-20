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

* New user option `agda-input-single-line` allows instructing the Agda
  input method from resizing the minibuffer.

Cubical Agda
------------

* Cubical Agda will now report boundary information for interaction
  points which are not at the top-level of their respective clauses.
  This includes bodies of `Path`-typed values, the faces of a partial
  element, arguments to functions returning paths, etc.

  Since this information is available in a structured way _during
  interaction_, the "goal type, context, and inferred type" command will
  also display the value of the expression at each relevant face.

  See also [PR #6529](https://github.com/agda/agda/pull/6529) for a
  deeper explanation and a demo video.
