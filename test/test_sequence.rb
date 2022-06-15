# frozen_string_literal: true

require 'minitest'
require 'minitest/autorun'

require 'markdoc'

class SequenceTest < Minitest::Test
  def test_pic_output
    code = <<~CODE
      Student = Actor
      P = Partner Site
      App = Web App
      Api = Reg API

      Student -> P : Choose course(S)
      P -> Api : Issue key for(S)
      P <~ Api : Registration key(K)
      P -> App : Register with key(K)
      Student <~ App : Registration form
      Student -> App : Fill the form(F)
      App : Save the form(F)
      App -> Api : Register(K, F) # New API
      Api : Create course
      App <~ Api : Course details(C)
      App : Save(C)
      Student <~ App : Show course summary
      Student -> Api : Click study button
      Student <~ Api : Show mypage
    CODE

    assert(!Markdoc::Sequence.draw(code).nil?)
  end
end
