# coding: utf-8
require 'minitest'
require 'minitest/autorun'

require 'markdoc'

class PseudocodeTest < Minitest::Test
  def test_conditional
    code = <<-CODE
if you thursty
  go to fridge
  if there is coke
    drink it
  else
    buy one 💰
  end
else
  open your laptop
  if there is new ✉
    read it
  else
    check your twitter
  end
end
CODE

    graphviz = <<-GRAPH
digraph G {
N1 [shape=diamond label="you thursty"]
N2 [shape=box label="go to fridge"]
N3 [shape=diamond label="there is coke"]
N4 [shape=box label="drink it"]
  N3 -> N4 [label="Yes"]
N5 [shape=box label="buy one 💰"]
  N3 -> N5 [label="No"]
N2 -> N3
  N1 -> N2 [label="Yes"]
N6 [shape=box label="open your laptop"]
N7 [shape=diamond label="there is new ✉"]
N8 [shape=box label="read it"]
  N7 -> N8 [label="Yes"]
N9 [shape=box label="check your twitter"]
  N7 -> N9 [label="No"]
N6 -> N7
  N1 -> N6 [label="No"]
}
GRAPH

    assert_equal graphviz, Markdoc::Pseudocode.draw(code, :graphviz)
  end

end
