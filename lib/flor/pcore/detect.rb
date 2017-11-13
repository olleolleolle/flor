
require 'flor/pcore/iterator'


class Flor::Pro::Detect < Flor::Macro::Iterator
  #
  # Detect is a simplified version of [find](find.md).
  #
  # ```
  # detect [ 1, 2, 3 ]
  #   (elt % 2) == 0
  # # f.ret --> 2
  # ```
  #
  # ## see also
  #
  # find.

  name 'detect'

  def rewrite_tree

    rewrite_iterator_tree('find')
  end
end
